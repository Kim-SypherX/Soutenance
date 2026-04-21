-- ============================================================
--  FITMOD — Base de Données v2 (Refonte)
--  Plateforme Web Tailleur-Client (Burkina Faso)
-- ============================================================

CREATE DATABASE IF NOT EXISTS fitmod_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE fitmod_db;

-- ============================================================
-- 1. UTILISATEUR (table centrale)
-- ============================================================
CREATE TABLE utilisateur (
  id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  nom             VARCHAR(80)     NOT NULL,
  prenom          VARCHAR(80)     NOT NULL,
  email           VARCHAR(150)    NOT NULL UNIQUE,
  mot_de_passe    VARCHAR(255)    NOT NULL,
  telephone       VARCHAR(20)     DEFAULT NULL,
  ville           VARCHAR(80)     DEFAULT NULL,
  type_compte     ENUM('client','tailleur','admin') NOT NULL DEFAULT 'client',
  date_inscription DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actif           TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id)
);

-- ============================================================
-- 2. TAILLEUR
-- ============================================================
CREATE TABLE tailleur (
  utilisateur_id  INT UNSIGNED    NOT NULL,
  nom_atelier     VARCHAR(150)    NOT NULL,
  adresse         VARCHAR(255)    DEFAULT NULL,
  quartier        VARCHAR(100)    DEFAULT NULL,
  specialites     VARCHAR(255)    DEFAULT NULL,
  tarif_min       DECIMAL(10,2)   DEFAULT 0.00,
  delai_moyen     INT UNSIGNED    DEFAULT NULL,
  note_moyenne    DECIMAL(3,2)    DEFAULT 0.00,
  statut          ENUM('actif','en_conge','suspendu') NOT NULL DEFAULT 'actif',
  valide_admin    TINYINT(1)      NOT NULL DEFAULT 0,
  PRIMARY KEY (utilisateur_id),
  CONSTRAINT fk_tailleur_utilisateur
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id)
    ON DELETE CASCADE
);

-- ============================================================
-- 3. MESURE
-- ============================================================
CREATE TABLE mesure (
  id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  utilisateur_id  INT UNSIGNED    NOT NULL UNIQUE,
  poitrine        DECIMAL(5,1)    DEFAULT NULL,
  taille          DECIMAL(5,1)    DEFAULT NULL,
  hanches         DECIMAL(5,1)    DEFAULT NULL,
  longueur_dos    DECIMAL(5,1)    DEFAULT NULL,
  longueur_bras   DECIMAL(5,1)    DEFAULT NULL,
  tour_cou        DECIMAL(5,1)    DEFAULT NULL,
  entrejambe      DECIMAL(5,1)    DEFAULT NULL,
  hauteur         DECIMAL(5,1)    DEFAULT NULL,
  mesures_json    JSON            DEFAULT NULL,
  date_prise      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_mesure_utilisateur
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id)
    ON DELETE CASCADE
);

-- ============================================================
-- 4. MODELE
-- ============================================================
CREATE TABLE modele (
  id                  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  tailleur_id         INT UNSIGNED    NOT NULL,
  titre               VARCHAR(150)    NOT NULL,
  description         TEXT            DEFAULT NULL,
  type_tenue          VARCHAR(80)     DEFAULT NULL,
  photo_url           VARCHAR(500)    DEFAULT NULL,
  modele_3d_url       VARCHAR(500)    DEFAULT NULL,
  prix_base           DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  delai_confection    INT UNSIGNED    DEFAULT NULL,
  couleurs_disponibles JSON           DEFAULT NULL,
  date_creation       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actif               TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  CONSTRAINT fk_modele_tailleur
    FOREIGN KEY (tailleur_id) REFERENCES tailleur(utilisateur_id)
    ON DELETE CASCADE
);

-- ============================================================
-- 5. COMMANDE
-- ============================================================
CREATE TABLE commande (
  id                      INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  client_id               INT UNSIGNED    NOT NULL,
  tailleur_id             INT UNSIGNED    NOT NULL,
  modele_id               INT UNSIGNED    NOT NULL,
  mesures_utilisees       JSON            NOT NULL,
  tissu_choisi            VARCHAR(100)    DEFAULT NULL,
  couleur                 VARCHAR(50)     DEFAULT NULL,
  prix_total              DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  statut                  ENUM('en_attente_acceptation','acceptee','tissu_decoupe','couture_en_cours','finitions','pret_a_recuperer','livre','annulee') NOT NULL DEFAULT 'en_attente_acceptation',
  date_commande           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_livraison_souhaitee DATE           DEFAULT NULL,
  date_livraison_reelle   DATE            DEFAULT NULL,
  notes_client            TEXT            DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_commande_client
    FOREIGN KEY (client_id) REFERENCES utilisateur(id),
  CONSTRAINT fk_commande_tailleur
    FOREIGN KEY (tailleur_id) REFERENCES tailleur(utilisateur_id),
  CONSTRAINT fk_commande_modele
    FOREIGN KEY (modele_id) REFERENCES modele(id)
);

-- ============================================================
-- 6. STATUT COMMANDE (historique)
-- ============================================================
CREATE TABLE statut_commande (
  id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  commande_id     INT UNSIGNED    NOT NULL,
  libelle         VARCHAR(100)    NOT NULL,
  commentaire     TEXT            DEFAULT NULL,
  date_heure      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_statut_commande
    FOREIGN KEY (commande_id) REFERENCES commande(id)
    ON DELETE CASCADE
);

-- ============================================================
-- 7. AVIS
-- ============================================================
CREATE TABLE avis (
  id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  commande_id     INT UNSIGNED    NOT NULL UNIQUE,
  client_id       INT UNSIGNED    NOT NULL,
  tailleur_id     INT UNSIGNED    NOT NULL,
  note            TINYINT UNSIGNED NOT NULL,
  commentaire     TEXT            DEFAULT NULL,
  date_avis       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_avis_commande
    FOREIGN KEY (commande_id) REFERENCES commande(id),
  CONSTRAINT fk_avis_client
    FOREIGN KEY (client_id) REFERENCES utilisateur(id),
  CONSTRAINT fk_avis_tailleur
    FOREIGN KEY (tailleur_id) REFERENCES tailleur(utilisateur_id)
);

-- ============================================================
-- 8. FAVORI
-- ============================================================
CREATE TABLE favori (
  id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  utilisateur_id  INT UNSIGNED    NOT NULL,
  modele_id       INT UNSIGNED    NOT NULL,
  date_ajout      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_favori (utilisateur_id, modele_id),
  CONSTRAINT fk_favori_utilisateur
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_favori_modele
    FOREIGN KEY (modele_id) REFERENCES modele(id)
    ON DELETE CASCADE
);

-- ============================================================
-- 9. CONVERSATION
-- ============================================================
CREATE TABLE conversation (
  id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  utilisateur1_id INT UNSIGNED    NOT NULL,
  utilisateur2_id INT UNSIGNED    NOT NULL,
  date_creation   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_conv_pair (utilisateur1_id, utilisateur2_id),
  CONSTRAINT fk_conv_user1
    FOREIGN KEY (utilisateur1_id) REFERENCES utilisateur(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_conv_user2
    FOREIGN KEY (utilisateur2_id) REFERENCES utilisateur(id)
    ON DELETE CASCADE
);

-- ============================================================
-- 10. MESSAGE
-- ============================================================
CREATE TABLE message (
  id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  conversation_id INT UNSIGNED    NOT NULL,
  expediteur_id   INT UNSIGNED    NOT NULL,
  type_message    ENUM('texte','audio','image') NOT NULL DEFAULT 'texte',
  contenu         TEXT            NOT NULL,
  date_heure      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  lu              TINYINT(1)      NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  CONSTRAINT fk_message_conversation
    FOREIGN KEY (conversation_id) REFERENCES conversation(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_message_expediteur
    FOREIGN KEY (expediteur_id) REFERENCES utilisateur(id)
);

-- ============================================================
-- 11. SESSION ESSAYAGE
-- ============================================================
CREATE TABLE session_essayage (
  id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  utilisateur_id  INT UNSIGNED    NOT NULL,
  modele_id       INT UNSIGNED    NOT NULL,
  date_session    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  capture_url     VARCHAR(500)    DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_session_utilisateur
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_session_modele
    FOREIGN KEY (modele_id) REFERENCES modele(id)
    ON DELETE CASCADE
);

-- ============================================================
-- 12. PAIEMENT
-- ============================================================
CREATE TABLE paiement (
  id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  commande_id     INT UNSIGNED    NOT NULL,
  payeur_id       INT UNSIGNED    NOT NULL,
  beneficiaire_id INT UNSIGNED    NOT NULL,
  montant         DECIMAL(10,2)   NOT NULL,
  methode         ENUM('mobile_money','carte','especes','virement') NOT NULL DEFAULT 'mobile_money',
  statut          ENUM('en_attente','valide','echoue','rembourse') NOT NULL DEFAULT 'en_attente',
  reference       VARCHAR(100)    DEFAULT NULL,
  date_paiement   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_paiement_commande
    FOREIGN KEY (commande_id) REFERENCES commande(id),
  CONSTRAINT fk_paiement_payeur
    FOREIGN KEY (payeur_id) REFERENCES utilisateur(id),
  CONSTRAINT fk_paiement_beneficiaire
    FOREIGN KEY (beneficiaire_id) REFERENCES utilisateur(id)
);

-- ============================================================
-- INDEX
-- ============================================================
CREATE INDEX idx_utilisateur_ville ON utilisateur(ville, type_compte);
CREATE INDEX idx_tailleur_statut ON tailleur(statut, valide_admin);
CREATE INDEX idx_commande_client ON commande(client_id, statut);
CREATE INDEX idx_commande_tailleur ON commande(tailleur_id, statut);
CREATE INDEX idx_message_conversation ON message(conversation_id, lu);
CREATE INDEX idx_modele_tailleur ON modele(tailleur_id, actif);
CREATE INDEX idx_mesure_utilisateur ON mesure(utilisateur_id);
CREATE INDEX idx_paiement_commande ON paiement(commande_id, statut);