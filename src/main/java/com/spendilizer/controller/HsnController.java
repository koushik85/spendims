package com.spendilizer.controller;

import com.spendilizer.entity.Hsn;
import com.spendilizer.service.HsnService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/hsn")
public class HsnController {

    private final HsnService hsnService;

    public HsnController(HsnService hsnService) {
        this.hsnService = hsnService;
    }

    @GetMapping("/search")
    public List<Hsn> searchHsn(@RequestParam String keyword) {
        return hsnService.search(keyword);
    }
}