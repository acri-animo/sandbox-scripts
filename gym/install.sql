CREATE TABLE player_gym (
    sid INT NOT NULL,
    situps INT DEFAULT 0,
    pushups INT DEFAULT 0,
    curls INT DEFAULT 0,
    pullups INT DEFAULT 0,
    jogging INT DEFAULT 0,
    yoga INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (sid)
);