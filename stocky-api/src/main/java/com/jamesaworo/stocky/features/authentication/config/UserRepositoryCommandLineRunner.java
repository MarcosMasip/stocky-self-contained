package com.jamesaworo.stocky.features.authentication.config;

import com.jamesaworo.stocky.features.authentication.data.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Simple runner to log how many users are present right after context startup
 * to verify seeding happened before first login attempt.
 */
@Component
@Profile("offline")
@RequiredArgsConstructor
public class UserRepositoryCommandLineRunner implements CommandLineRunner {
    private static final Logger log = LoggerFactory.getLogger(UserRepositoryCommandLineRunner.class);
    private final UserRepository userRepository;

    @Override
    public void run(String... args) {
        long count = userRepository.count();
        log.info("[offline] User repository count at startup: {}", count);
    }
}
