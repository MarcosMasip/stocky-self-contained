/*
 * @Author: james.junior
 * @Date: 8/6/23 02:31
 *
 * @Project: stocky-api
 */

package com.jamesaworo.stocky.features.authentication.endpoint;

import com.jamesaworo.stocky.features.authentication.data.interactor.contract.ILoginInteractor;
import com.jamesaworo.stocky.features.authentication.data.request.LoginRequest;
import com.jamesaworo.stocky.features.authentication.data.request.LoginResponse;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

import static com.jamesaworo.stocky.core.constants.Global.API_PREFIX;


@RestController
@RequestMapping(value = API_PREFIX + "/auth")
@RequiredArgsConstructor
public class LoginEndpoint {

    private final ILoginInteractor interactor;
    private static final Logger log = LoggerFactory.getLogger(LoginEndpoint.class);

    // Leading slash required so final path becomes /api/v1/auth/login (previously /api/v1/authlogin)
    @PostMapping(value = "/login")
    ResponseEntity<LoginResponse> login(
            @Valid @RequestBody LoginRequest request
    ) {
        log.info("Login attempt for username='{}'", request.getUsername());
        ResponseEntity<LoginResponse> response = this.interactor.login(request);
        if (response.getBody() != null && response.getBody().getUser() != null) {
            log.info("Login success username='{}' id={}", response.getBody().getUser().getUsername(), response.getBody().getUser().getId());
        }
        return response;
    }
}
