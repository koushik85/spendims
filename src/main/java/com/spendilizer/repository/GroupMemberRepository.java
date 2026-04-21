package com.spendilizer.repository;

import com.spendilizer.entity.GroupMember;
import com.spendilizer.entity.SplitGroup;
import com.spendilizer.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {
    List<GroupMember> findBySplitGroup(SplitGroup splitGroup);
    List<GroupMember> findByLinkedUser(User linkedUser);
    Optional<GroupMember> findBySplitGroupAndLinkedUser(SplitGroup splitGroup, User linkedUser);
    /** Finds unlinked member slots whose email matches — used to auto-link on registration. */
    List<GroupMember> findByEmailAndLinkedUserIsNull(String email);
}
