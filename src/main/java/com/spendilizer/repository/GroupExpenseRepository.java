package com.spendilizer.repository;

import com.spendilizer.entity.GroupExpense;
import com.spendilizer.entity.SplitGroup;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GroupExpenseRepository extends JpaRepository<GroupExpense, Long> {
    List<GroupExpense> findBySplitGroupOrderByExpenseDateAscCreatedAtAsc(SplitGroup splitGroup);
}
