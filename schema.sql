CREATE DATABASE IF NOT EXISTS duwiki;
USE duwiki;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL COMMENT 'Store strong password hash (e.g., bcrypt/argon2), never plaintext.',
  your_work VARCHAR(255) NOT NULL COMMENT 'Signup prompt: Your work',
  for_use VARCHAR(255) NOT NULL COMMENT 'Signup prompt: For use',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE wiki_categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  description TEXT NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_wiki_categories_name (name),
  CONSTRAINT fk_wiki_categories_created_by
    FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE wiki_pages (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL UNIQUE,
  category_id BIGINT UNSIGNED NULL,
  author_id BIGINT UNSIGNED NULL,
  content LONGTEXT NOT NULL,
  custom_decoration_html LONGTEXT NULL COMMENT 'Raw HTML decoration. Render only after sanitization/trusted checks.',
  custom_decoration_script LONGTEXT NULL COMMENT 'Raw script decoration. Execute only in trusted/sandboxed contexts.',
  decoration_trust_level ENUM('sanitized','trusted','blocked') NOT NULL DEFAULT 'blocked' COMMENT 'blocked=not renderable, sanitized=render after sanitizer, trusted=approved trusted content.',
  decoration_approved_by BIGINT UNSIGNED NULL,
  decoration_approved_at TIMESTAMP NULL DEFAULT NULL,
  decoration_sanitized_at TIMESTAMP NULL DEFAULT NULL,
  is_published BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_wiki_pages_category
    FOREIGN KEY (category_id) REFERENCES wiki_categories(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT fk_wiki_pages_author
    FOREIGN KEY (author_id) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT fk_wiki_pages_approved_by
    FOREIGN KEY (decoration_approved_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
