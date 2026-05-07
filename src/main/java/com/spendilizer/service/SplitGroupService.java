package com.spendilizer.service;

import com.spendilizer.dto.MemberBalanceDto;
import com.spendilizer.dto.SettlementDto;
import com.spendilizer.entity.*;
import com.spendilizer.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class SplitGroupService {

    private final SplitGroupRepository splitGroupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final GroupExpenseRepository groupExpenseRepository;
    private final ExpenseSplitRepository expenseSplitRepository;
    private final UserRepository userRepository;

    public SplitGroupService(SplitGroupRepository splitGroupRepository,
                             GroupMemberRepository groupMemberRepository,
                             GroupExpenseRepository groupExpenseRepository,
                             ExpenseSplitRepository expenseSplitRepository,
                             UserRepository userRepository) {
        this.splitGroupRepository = splitGroupRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.groupExpenseRepository = groupExpenseRepository;
        this.expenseSplitRepository = expenseSplitRepository;
        this.userRepository = userRepository;
    }

    /**
     * Returns all groups the user has access to:
     * - groups they created
     * - groups where they are a linked member
     */
    public List<SplitGroup> getAllGroups(User user) {
        LinkedHashSet<SplitGroup> all = new LinkedHashSet<>(
                splitGroupRepository.findAllByCreatedByOrderByCreatedAtDesc(user));
        groupMemberRepository.findByLinkedUser(user).stream()
                .map(GroupMember::getSplitGroup)
                .forEach(all::add);
        return all.stream()
                .sorted(Comparator.comparing(SplitGroup::getCreatedAt).reversed())
                .collect(Collectors.toList());
    }

    public Optional<SplitGroup> getGroupById(Long id, User user) {
        // Creator access
        Optional<SplitGroup> byCreator = splitGroupRepository.findByIdAndCreatedBy(id, user);
        if (byCreator.isPresent()) return byCreator;
        // Linked member access
        return splitGroupRepository.findById(id).filter(group ->
                groupMemberRepository.findBySplitGroup(group).stream()
                        .anyMatch(m -> m.getLinkedUser() != null
                                && m.getLinkedUser().getUserId() == user.getUserId()));
    }

    /** Finds the GroupMember record for the current user in a group. */
    public Optional<GroupMember> getMemberForUser(SplitGroup group, User user) {
        return groupMemberRepository.findBySplitGroupAndLinkedUser(group, user);
    }

    @Transactional
    public SplitGroup createGroup(String name, String description, LocalDate eventDate,
                                  List<String> memberNames, List<String> memberEmails,
                                  User creator) {
        SplitGroup group = new SplitGroup();
        group.setName(name);
        group.setDescription(description);
        group.setEventDate(eventDate);
        group.setCreatedBy(creator);
        group.setStatus(Status.ACTIVE);
        SplitGroup saved = splitGroupRepository.save(group);

        // Always add the creator as first member
        String creatorFirstName = creator.getUserBasicDetails() != null ? creator.getUserBasicDetails().getUserFirstName() : "";
        String creatorLastName = creator.getUserBasicDetails() != null ? creator.getUserBasicDetails().getUserLastName() : "";
        GroupMember creatorMember = new GroupMember(saved,
                (creatorFirstName + " " + creatorLastName).trim(),
                creator.getUserEmail(), creator);
        groupMemberRepository.save(creatorMember);

        // Add other members
        for (int i = 0; i < memberNames.size(); i++) {
            String mName = memberNames.get(i).trim();
            if (mName.isBlank()) continue;
            String mEmail = (memberEmails != null && i < memberEmails.size())
                    ? memberEmails.get(i).trim() : null;
            // Link to registered user if email matches
            User linked = (mEmail != null && !mEmail.isBlank())
                    ? userRepository.findByUserEmail(mEmail) : null;
            groupMemberRepository.save(new GroupMember(saved, mName,
                    mEmail != null && !mEmail.isBlank() ? mEmail : null, linked));
        }
        return saved;
    }

    @Transactional
    public void addMember(Long groupId, String name, String email, User requestingUser) {
        SplitGroup group = getGroupById(groupId, requestingUser)
                .orElseThrow(() -> new RuntimeException("Group not found"));
        if (group.getCreatedBy().getUserId() != requestingUser.getUserId()) {
            throw new IllegalStateException("Only the group creator can add members.");
        }
        String trimEmail = (email != null && !email.isBlank()) ? email.trim() : null;
        User linked = trimEmail != null ? userRepository.findByUserEmail(trimEmail) : null;
        GroupMember newMember = groupMemberRepository.save(
                new GroupMember(group, name.trim(), trimEmail, linked));

        // Retroactively include this member in all existing expenses
        recalculateForNewMember(group, newMember);
    }

    /**
     * Called whenever a new member joins a group that already has expenses.
     * EQUAL expenses are fully recalculated across the new member count.
     * CUSTOM expenses get a ₹0 placeholder so the new member appears in balances.
     */
    private void recalculateForNewMember(SplitGroup group, GroupMember newMember) {
        List<GroupExpense> expenses = groupExpenseRepository
                .findBySplitGroupOrderByExpenseDateAscCreatedAtAsc(group);
        if (expenses.isEmpty()) return;

        List<GroupMember> allMembers = groupMemberRepository.findBySplitGroup(group);

        for (GroupExpense expense : expenses) {
            if (expense.getSplitType() == SplitType.EQUAL) {
                // Delete existing splits and redistribute equally
                expenseSplitRepository.deleteAll(expenseSplitRepository.findByExpense(expense));

                BigDecimal share = expense.getAmount()
                        .divide(BigDecimal.valueOf(allMembers.size()), 2, RoundingMode.HALF_UP);
                BigDecimal remainder = expense.getAmount()
                        .subtract(share.multiply(BigDecimal.valueOf(allMembers.size())));

                for (int i = 0; i < allMembers.size(); i++) {
                    BigDecimal memberShare = (i == 0) ? share.add(remainder) : share;
                    expenseSplitRepository.save(new ExpenseSplit(expense, allMembers.get(i), memberShare));
                }
            } else {
                // CUSTOM: add ₹0 — the creator can edit the expense if needed
                expenseSplitRepository.save(new ExpenseSplit(expense, newMember, BigDecimal.ZERO));
            }
        }
    }

    /**
     * Adds an expense paid by the current user.
     * paidBy is resolved automatically from the current user's member record.
     */
    @Transactional
    public GroupExpense addExpense(Long groupId, String description, BigDecimal amount,
                                   SplitType splitType, LocalDate expenseDate,
                                   Map<Long, BigDecimal> customShares, User currentUser) {
        SplitGroup group = getGroupById(groupId, currentUser)
                .orElseThrow(() -> new RuntimeException("Group not found"));

        GroupMember paidBy = getMemberForUser(group, currentUser)
                .orElseThrow(() -> new IllegalStateException(
                        "You are not a linked member of this group."));

        GroupExpense expense = new GroupExpense();
        expense.setSplitGroup(group);
        expense.setDescription(description);
        expense.setAmount(amount);
        expense.setPaidBy(paidBy);
        expense.setSplitType(splitType);
        expense.setExpenseDate(expenseDate);
        GroupExpense saved = groupExpenseRepository.save(expense);

        List<GroupMember> members = groupMemberRepository.findBySplitGroup(group);

        if (splitType == SplitType.EQUAL) {
            BigDecimal share = amount.divide(BigDecimal.valueOf(members.size()), 2, RoundingMode.HALF_UP);
            BigDecimal remainder = amount.subtract(share.multiply(BigDecimal.valueOf(members.size())));
            for (int i = 0; i < members.size(); i++) {
                BigDecimal memberShare = (i == 0) ? share.add(remainder) : share;
                expenseSplitRepository.save(new ExpenseSplit(saved, members.get(i), memberShare));
            }
        } else {
            for (GroupMember member : members) {
                BigDecimal share = customShares.getOrDefault(member.getId(), BigDecimal.ZERO);
                expenseSplitRepository.save(new ExpenseSplit(saved, member, share));
            }
        }
        return saved;
    }

    @Transactional
    public void deleteExpense(Long expenseId, Long groupId, User user) {
        SplitGroup group = getGroupById(groupId, user)
                .orElseThrow(() -> new RuntimeException("Group not found"));
        GroupExpense exp = groupExpenseRepository.findById(expenseId)
                .orElseThrow(() -> new RuntimeException("Expense not found"));
        // Only the payer or group creator can delete
        boolean isPayer = exp.getPaidBy().getLinkedUser() != null
                && exp.getPaidBy().getLinkedUser().getUserId() == user.getUserId();
        boolean isCreator = group.getCreatedBy().getUserId() == user.getUserId();
        if (!isPayer && !isCreator) {
            throw new IllegalStateException("Only the payer or group creator can delete an expense.");
        }
        groupExpenseRepository.delete(exp);
    }

    @Transactional
    public void closeGroup(Long groupId, User user) {
        SplitGroup group = splitGroupRepository.findByIdAndCreatedBy(groupId, user)
                .orElseThrow(() -> new RuntimeException("Group not found or you are not the creator."));
        group.setStatus(Status.INACTIVE);
        splitGroupRepository.save(group);
    }

    @Transactional
    public void deleteGroup(Long groupId, User user) {
        SplitGroup group = splitGroupRepository.findByIdAndCreatedBy(groupId, user)
                .orElseThrow(() -> new RuntimeException("Group not found or you are not the creator."));
        splitGroupRepository.delete(group);
    }

    public List<MemberBalanceDto> computeBalances(SplitGroup group) {
        List<GroupMember> members = groupMemberRepository.findBySplitGroup(group);
        List<GroupExpense> expenses = groupExpenseRepository
                .findBySplitGroupOrderByExpenseDateAscCreatedAtAsc(group);

        Map<Long, BigDecimal> paid = new HashMap<>();
        Map<Long, BigDecimal> owed = new HashMap<>();
        for (GroupMember m : members) {
            paid.put(m.getId(), BigDecimal.ZERO);
            owed.put(m.getId(), BigDecimal.ZERO);
        }
        for (GroupExpense exp : expenses) {
            Long payerId = exp.getPaidBy().getId();
            paid.merge(payerId, exp.getAmount(), BigDecimal::add);
            for (ExpenseSplit split : exp.getSplits()) {
                owed.merge(split.getMember().getId(), split.getShareAmount(), BigDecimal::add);
            }
        }
        List<MemberBalanceDto> result = new ArrayList<>();
        for (GroupMember m : members) {
            result.add(new MemberBalanceDto(m.getId(), m.getName(),
                    paid.getOrDefault(m.getId(), BigDecimal.ZERO),
                    owed.getOrDefault(m.getId(), BigDecimal.ZERO)));
        }
        return result;
    }

    public List<SettlementDto> computeSettlements(List<MemberBalanceDto> balances) {
        String[] creditNames = balances.stream()
                .filter(b -> b.getNetBalance().compareTo(BigDecimal.ZERO) > 0)
                .sorted(Comparator.comparing(MemberBalanceDto::getNetBalance).reversed())
                .map(MemberBalanceDto::getMemberName).toArray(String[]::new);
        String[] debtNames = balances.stream()
                .filter(b -> b.getNetBalance().compareTo(BigDecimal.ZERO) < 0)
                .sorted(Comparator.comparing(MemberBalanceDto::getNetBalance))
                .map(MemberBalanceDto::getMemberName).toArray(String[]::new);
        BigDecimal[] credits = balances.stream()
                .filter(b -> b.getNetBalance().compareTo(BigDecimal.ZERO) > 0)
                .sorted(Comparator.comparing(MemberBalanceDto::getNetBalance).reversed())
                .map(MemberBalanceDto::getNetBalance).toArray(BigDecimal[]::new);
        BigDecimal[] debts = balances.stream()
                .filter(b -> b.getNetBalance().compareTo(BigDecimal.ZERO) < 0)
                .sorted(Comparator.comparing(MemberBalanceDto::getNetBalance))
                .map(b -> b.getNetBalance().negate()).toArray(BigDecimal[]::new);

        List<SettlementDto> settlements = new ArrayList<>();
        int ci = 0, di = 0;
        while (ci < credits.length && di < debts.length) {
            BigDecimal settle = credits[ci].min(debts[di]);
            settlements.add(new SettlementDto(debtNames[di], creditNames[ci],
                    settle.setScale(2, RoundingMode.HALF_UP)));
            credits[ci] = credits[ci].subtract(settle);
            debts[di] = debts[di].subtract(settle);
            if (credits[ci].compareTo(BigDecimal.ZERO) == 0) ci++;
            if (debts[di].compareTo(BigDecimal.ZERO) == 0) di++;
        }
        return settlements;
    }
}
