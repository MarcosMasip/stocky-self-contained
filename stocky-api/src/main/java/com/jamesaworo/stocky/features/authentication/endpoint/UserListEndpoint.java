package com.jamesaworo.stocky.features.authentication.endpoint;

import com.jamesaworo.stocky.features.authentication.data.repository.UserRepository;
import com.jamesaworo.stocky.features.authentication.domain.entity.User;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

import static com.jamesaworo.stocky.core.constants.Global.API_PREFIX;

@RestController
@RequestMapping(API_PREFIX + "/auth")
@RequiredArgsConstructor
public class UserListEndpoint {
    private static final Logger log = LoggerFactory.getLogger(UserListEndpoint.class);
    private final UserRepository userRepository;

    @GetMapping("/users")
    public ResponseEntity<List<String>> list() {
    List<String> users = userRepository.findAll().stream()
        .map(u -> u.getUsername() + (Boolean.TRUE.equals(u.getIsActiveStatus()) ? "" : " (inactive)"))
        .collect(Collectors.toList());
        log.info("Listing users: {}", users);
        return ResponseEntity.ok(users);
    }
}
