package com.spendilizer.service;

import com.spendilizer.entity.Hsn;
import com.spendilizer.repository.HsnRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HsnService {

   private final HsnRepository hsnRepository;

    public HsnService(HsnRepository hsnRepository) {
        this.hsnRepository = hsnRepository;
    }

    public List<Hsn> search(String keyword) {
        Pageable limit = PageRequest.of(0, 10); // top 10 results
        return hsnRepository.search(keyword, limit);
    }
}
