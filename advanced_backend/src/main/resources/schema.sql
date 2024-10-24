CREATE SCHEMA IF NOT EXISTS advanced_db;

SET client_encoding = 'UTF-8';
SET standard_conforming_strings = on;
SET TIME ZONE 'America/Sao_Paulo';

\c advanced_db;

DROP TABLE IF EXISTS Users;

CREATE TABLE Users
(
    id         BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    email      VARCHAR(100) NOT NULL,
    password   VARCHAR(255) DEFAULT NULL,
    address    VARCHAR(255) DEFAULT NULL,
    phone      VARCHAR(30)  DEFAULT NULL,
    title      VARCHAR(50)  DEFAULT NULL,
    bio        VARCHAR(255) DEFAULT NULL,
    enable     BOOLEAN      DEFAULT FALSE,
    non_locked BOOLEAN      DEFAULT TRUE,
    using_mfa  BOOLEAN      DEFAULT FALSE,
    image_url  VARCHAR(255) DEFAULT './static/images/profile-user.png',
    created_at DATE         DEFAULT current_timestamp,
    CONSTRAINT UQ_Users_Email UNIQUE (email)
);

DROP TABLE IF EXISTS Roles;

CREATE TABLE Roles
(
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL,
    permissions VARCHAR(255) NOT NULL,
    CONSTRAINT UQ_Roles_Name UNIQUE (name)

);

DROP TABLE IF EXISTS UserRoles;

CREATE TABLE UserRoles
(
    id      BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL CHECK ( user_id >= 0 ),
    role_id BIGINT NOT NULL CHECK ( role_id >= 0 ),
    FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (role_id) REFERENCES Roles (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT UQ_UserRoles_User_Id UNIQUE (user_id)

);

DROP TABLE IF EXISTS Events;

CREATE TABLE Events
(
    id          BIGSERIAL PRIMARY KEY,
    type        VARCHAR(50)  NOT NULL CHECK ( type IN
                                              ('LOGIN_ATTEMPT', 'LOGIN_ATTEMPT_FAILURE', 'LOGGING_ATTEMPT_SUCCESS',
                                               'PROFILE_UPDATE', 'PROFILE_PICTURE_UPDATE', 'ROLE_UPDATE',
                                               'ACCOUNT_SETTINGS_UPDATE', 'PASSWORD_UPDATE', 'MFA_UPDATE')),
    description VARCHAR(255) NOT NULL,
    CONSTRAINT UQ_Events_Type UNIQUE (type)
);

DROP TABLE IF EXISTS UserEvents;

CREATE TABLE UserEvents
(
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT NOT NULL,
    event_id   BIGINT NOT NULL,
    device     VARCHAR(100) DEFAULT NULL,
    ip_address VARCHAR(100) DEFAULT NULL,
    created_at DATE         DEFAULT current_timestamp,
    FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (event_id) REFERENCES Events (id) ON DELETE RESTRICT ON UPDATE CASCADE

);

DROP TABLE IF EXISTS AccountVerifications;

CREATE TABLE AccountVerifications
(
    id      BIGSERIAL PRIMARY KEY,
    user_id BIGINT       NOT NULL,
    url     VARCHAR(255) NOT NULL,
    -- date DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT UQ_AccountVerifications_User_Id UNIQUE (user_id),
    CONSTRAINT UQ_AccountVerifications_Url UNIQUE (url)
);

DROP TABLE IF EXISTS ResetPasswordVerifications;

CREATE TABLE ResetPasswordVerifications
(
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT       NOT NULL,
    url             VARCHAR(255) NOT NULL,
    expiration_date DATE         NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users (id) ON UPDATE CASCADE ON UPDATE CASCADE,
    CONSTRAINT UQ_ResetPasswordVerifications_User_Id UNIQUE (user_id),
    CONSTRAINT UQ_ResetPasswordVerifications_Url UNIQUE (url)
);

DROP TABLE IF EXISTS TwoFactorVerifications;

CREATE TABLE TwoFactorVerifications
(
    id BIGSERIAL PRIMARY KEY ,
    user_id BIGINT NOT NULL ,
    code VARCHAR(10) NOT NULL ,
    expiration_date DATE NOT NULL ,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON UPDATE CASCADE ON DELETE CASCADE ,
    CONSTRAINT UQ_TwoFactorVerifications_User_Id UNIQUE (user_id),
    CONSTRAINT UQ_TwoFactorVerifications_Code UNIQUE (code)
);

