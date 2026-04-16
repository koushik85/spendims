package com.spendilizer.controller;

import com.spendilizer.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class SignupController {

    private static final Logger logger = LoggerFactory.getLogger(SignupController.class);

    private final UserService userService;

    public SignupController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/signup")
    public String getSignup() {
        return "signup";
    }

    private static final java.util.regex.Pattern PAN_PATTERN =
            java.util.regex.Pattern.compile("^[A-Z]{5}[0-9]{4}[A-Z]$");

    @PostMapping("/signup")
    public String doSignup(
            @RequestParam("accountType") String accountType,
            @RequestParam("email") String email,
            @RequestParam("firstName") String firstName,
            @RequestParam("lastName") String lastName,
            @RequestParam("password") String password,
            @RequestParam("confirmPassword") String confirmPassword,
            @RequestParam(value = "pan", required = false) String pan,
            @RequestParam(value = "enterpriseName", required = false) String enterpriseName,
            Model model) {

        if (!password.equals(confirmPassword)) {
            logger.warn("SIGNUP_REJECTED reason=password_mismatch accountType={} email={}", accountType, email);
            model.addAttribute("error", "Passwords do not match.");
            model.addAttribute("activeTab", accountType);
            return "signup";
        }

        if (pan != null && !pan.isBlank()) {
            if (!PAN_PATTERN.matcher(pan.toUpperCase()).matches()) {
                logger.warn("SIGNUP_REJECTED reason=invalid_pan accountType={} email={}", accountType, email);
                model.addAttribute("error", "Invalid PAN number. Format: 5 letters, 4 digits, 1 letter (e.g. ABCDE1234F).");
                model.addAttribute("activeTab", accountType);
                return "signup";
            }
        }

        if (userService.emailExists(email)) {
            logger.warn("SIGNUP_REJECTED reason=duplicate_email accountType={} email={}", accountType, email);
            model.addAttribute("error", "An account with this email already exists.");
            model.addAttribute("activeTab", accountType);
            return "signup";
        }

        try {
            if ("ENTERPRISE".equals(accountType)) {
                if (enterpriseName == null || enterpriseName.trim().isEmpty()) {
                    logger.warn("SIGNUP_REJECTED reason=missing_enterprise_name accountType={} email={}", accountType, email);
                    model.addAttribute("error", "Company name is required for enterprise accounts.");
                    model.addAttribute("activeTab", accountType);
                    return "signup";
                }
                userService.registerEnterpriseOwner(email, firstName, lastName, password, enterpriseName.trim(), pan);
            } else {
                userService.registerIndividualUser(email, firstName, lastName, password, pan);
            }

            logger.info("SIGNUP_SUCCESS accountType={} email={}", accountType, email);
            return "redirect:/login?registered=true";
        } catch (Exception exception) {
            logger.error("SIGNUP_FAILED accountType={} email={} reason={}",
                    accountType,
                    email,
                    exception.getClass().getSimpleName());
            model.addAttribute("error", "Signup failed. Please try again.");
            model.addAttribute("activeTab", accountType);
            return "signup";
        }
    }
}
