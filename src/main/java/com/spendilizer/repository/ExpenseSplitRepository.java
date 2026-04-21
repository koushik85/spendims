package com.spendilizer.repository;

import com.spendilizer.entity.ExpenseSplit;
import com.spendilizer.entity.GroupExpense;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ExpenseSplitRepository extends JpaRepository<ExpenseSplit, Long> {
    List<ExpenseSplit> findByExpense(GroupExpense expense);
}
