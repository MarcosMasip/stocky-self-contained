package com.jamesaworo.stocky.features.authentication.endpoint;

import com.jamesaworo.stocky.features.authentication.data.repository.UserRepository;
import com.jamesaworo.stocky.features.authentication.domain.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

import static com.jamesaworo.stocky.core.constants.Global.API_PREFIX;

/**
 * Temporary debug endpoint (offline profile usage) to list seeded users.
 * Can be removed once login issue is fully validated.
 */
@RestController
@RequestMapping(API_PREFIX + "/auth/debug")
@RequiredArgsConstructor
public class DebugUserEndpoint {
    private final UserRepository userRepository;

    @GetMapping("/users")
    public ResponseEntity<List<String>> users() {
        List<String> names = userRepository.findAll().stream()
                .map(u -> u.getId() + ":" + u.getUsername())
                .collect(Collectors.toList());
        return ResponseEntity.ok(names);
    }
}
