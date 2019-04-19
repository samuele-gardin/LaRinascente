--
-- Database: `larinascente_gardin_peron`
--

CREATE DATABASE larinascente_gardin_peron;
USE larinascente_gardin_peron;

--
-- Procedure
--

DELIMITER $$

CREATE PROCEDURE `cheCodiceHaQuestoArticolo`(IN `nomeIn` VARCHAR(50))
BEGIN 
	SELECT codice, nome, categoria 
	FROM ( 
		SELECT codiceArtMag AS codice, nomeArt AS nome, tipoArt AS 	categoria 
		FROM articolomag 
		UNION ALL 
		SELECT codiceAli AS codice, nomeAli AS nome, 'alimenti' AS 	categoria 
		FROM alimento 
	) AS unione 
	WHERE nome LIKE CONCAT('%', nomeIn, '%'); 
END$$

CREATE PROCEDURE `ricettaPerNPersone`(IN `nPersone` INT, IN `codRicetta` VARCHAR(15))
BEGIN 
	DECLARE nP INT; 
	SET nP = ( 
		SELECT numPersone 
		FROM ricetta 
		WHERE codiceRicetta = codRicetta 
	); 
	SELECT a.nomeALi, 
	cast((i.quantitaIng*nPersone) / nP AS decimal(6, 0)) 
	AS quantitaIng, i.unitaMisura 
	FROM ingrediente i, alimento a 
	WHERE i.codiceRicetta = codRicetta AND a.codiceALi = i.codiceAli; 
END$$

--
-- Funzioni
--
CREATE FUNCTION `contaScaduti`() RETURNS int(11)
    NO SQL
BEGIN
	DECLARE contatore INT; 
	SET contatore = ( 
		SELECT COUNT(*) 
		FROM alimento 
		WHERE dataScad < CURDATE() 
	); 
	RETURN contatore; 
END$$

CREATE FUNCTION `controllaScaduti`(`codiceA` VARCHAR(15)) RETURNS varchar(80)
BEGIN
	DECLARE scaduto BOOLEAN; 
	DECLARE nome VARCHAR(80); 
	SELECT COUNT(*) INTO scaduto FROM alimento 
	WHERE codiceAli = codiceA AND dataScad < CURDATE(); 
	SELECT nomeALi INTO nome FROM alimento 
	WHERE codiceAli = codiceA; 
	IF(scaduto) 
	THEN 
	RETURN concat(nome, " È SCADUTO"); 
	ELSE 
	RETURN concat(nome, " NON È SCADUTO"); 
	END IF; 
END$$

CREATE FUNCTION `nomeGiusto`(`codiceIn` VARCHAR(15)) RETURNS varchar(50)
BEGIN
	DECLARE nomeRis VARCHAR(50); 
	SELECT nome INTO nomeRis
	FROM ( 
		SELECT codiceArtMag AS codice, nomeArt AS nome, tipoArt AS 	categoria 
		FROM articolomag 
		UNION ALL 
		SELECT codiceAli AS codice, nomeAli AS nome, 'alimenti' AS 	categoria 
		FROM alimento 
	) AS unione 
	WHERE codice = codiceIn;
	RETURN nomeRis; 
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `cella`
--

CREATE TABLE `cella` (
	`numeroCella` int(11) NOT NULL PRIMARY KEY,
	`tipoCella` enum('salumi','formaggi','verdure','surgelati') NOT NULL
);

--
-- Dump dei dati per la tabella `cella`
--

INSERT INTO `cella` (`numeroCella`, `tipoCella`) VALUES
(1, 'salumi'),
(2, 'verdure'),
(3, 'formaggi'),
(4, 'surgelati');

-- --------------------------------------------------------

--
-- Struttura della tabella `personale`
--

CREATE TABLE `personale` (
  `codicePers` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `nome` varchar(15) NOT NULL,
  `cognome` varchar(15) NOT NULL,
  `CF` char(16) NOT NULL,
  `numTel` varchar(14) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `ruolo` enum('magazziniere','cuoco','capocuoco','operatore','servizioGenerale','direttore','centralinista','altro') NOT NULL
);

--
-- Dump dei dati per la tabella `personale`
--

INSERT INTO `personale` (`codicePers`, `nome`, `cognome`, `CF`, `numTel`, `email`, `ruolo`) VALUES
(1, 'Carlo', ' Bianchi', 'BNCCRL80A01B563I', '0499221289', 'carlobianchi@gmail.com', 'cuoco'),
(2, 'Giulio', 'Golia', 'GLOGLI64A01G224T', '0499220313', 'giuliogolia@gmail.com', 'cuoco'),
(3, 'Paola', 'Rossi', 'RSSPLA68A41G224D', '041469378', 'paolarossi@gmail.com', 'cuoco'),
(4, 'Giovanna', 'Minto', 'MNTGNN80M41L781F', '3393047959', 'giovannaminto@gmail.com', 'cuoco'),
(5, 'Claudio', 'Penna', 'PNNCLD70M06G224N', '3487859621', 'claudiopenna@gmail.com', 'capocuoco'),
(10, 'Giorgia', 'Panna', 'PNNGRG80A41G224Y', '3467854368', 'giorgiapanna@live.it', 'operatore'),
(11, 'ciccio', 'puzzo', 'cicciopuzzo54', '0499302755', 'ciccio.puzzo54@gmail.com', 'operatore'),
(13, 'samuel', 'dari', 'DRASML80A01C743S', '3456587320', 'samueldari@gmail.com', 'magazziniere'),
(14, 'giovanni', 'storti', 'STRGNN57B20F205U', '3698745321', 'giovannistorti@gmail.com', 'magazziniere'),
(15, 'aldo', 'baglio', 'LDABGL58P28G273B', '0462556431', 'aldobaglio@gmail.com', 'magazziniere'),
(16, 'giacomo', 'poretti', 'GCMPTT56D26L928X', '3456534962', 'giacomoporetti@gmail.com', 'magazziniere');

-- --------------------------------------------------------

--
-- Struttura della tabella `stanzadimagazzino`
--

CREATE TABLE `stanzadimagazzino` (
	`pianoStanza` varchar(5) NOT NULL PRIMARY KEY,
	`codiceMgznr` int(11) NOT NULL,
	FOREIGN KEY (`codiceMgznr`) REFERENCES `personale`(`codicePers`)
);

--
-- Dump dei dati per la tabella `stanzadimagazzino`
--

INSERT INTO `stanzadimagazzino` (`pianoStanza`, `codiceMgznr`) VALUES
('004', 13),
('101', 13),
('001', 14),
('002', 14),
('003', 15),
('201', 16);

-- --------------------------------------------------------

--
-- Struttura della tabella `fornitore`
--

CREATE TABLE `fornitore` (
	`pIva` char(11) NOT NULL PRIMARY KEY,
	`denominazione` varchar(50) NOT NULL,
	`numTelFor` varchar(14) NOT NULL,
	`email` varchar(50) DEFAULT NULL
);

--
-- Dump dei dati per la tabella `fornitore`
--

INSERT INTO `fornitore` (`pIva`, `denominazione`, `numTelFor`, `email`) VALUES
('00125498351', 'FOOD & FOOD SRL', '3487851460', 'food&food@gmail.com'),
('11445236974', 'DA FROM SRL', '3398752145', 'daFrom.srl@gmail.com'),
('14583796425', 'Caffè Carraro s.p.a', '3564897512', 'carraro.caffe@alice.it'),
('19632587456', 'I FRESCHI & CO SRL', '3651248845', 'ifreschiSRL@gmail.com'),
('22556487621', 'F.G.F. Dolciaria Pordenonese SRL', '0429556547', 'dolciariaFGF@gmail.com'),
('24698315789', 'ORTOFRUTTICOLA EUGANEA DI SQUARCINA G. &', '3489625145', 'ortofrutta.squarcina@hotmail.it'),
('26971442321', 'ITALCHIMICA SRL', '0498792456', 'info@italchimica.it'),
('38544768294', 'Alchimia Detergenti', '3468951307', 'alchimia@hotmail.it'),
('87896521463', 'TESSILITALY s.r.l', '0492865172', 'tessilitaly@yahoo.com'),
('88882563941', 'HDS FOODSERVICE SRL - DIVISIONE ROBO', '0496325871', 'hds-foodserviceROBO@gmail.com'),
('99546325554', 'f.ll.i Longhin', '3564211235', 'longhinFabiano@libero.it');

-- --------------------------------------------------------

--
-- Struttura della tabella `articoloordinabile`
--

CREATE TABLE `articoloordinabile` (
	`codiceArtOrd` int(11) NOT NULL PRIMARY KEY,
	`nomeArt` varchar(25) NOT NULL,
	`pIvaFornitore` char(11) NOT NULL,
	FOREIGN KEY (`pIvaFornitore`) REFERENCES `fornitore`(`pIva`)
);

--
-- Dump dei dati per la tabella `articoloordinabile`
--

INSERT INTO `articoloordinabile` (`codiceArtOrd`, `nomeArt`, `pIvaFornitore`) VALUES
(1, 'LATTE UHT P.S. LT 1 NR=1L', '00125498351'),
(2, 'PASTA DI SEMOLA KG 5', '00125498351'),
(3, 'BURRO KG 1', '19632587456'),
(4, 'spugne', '99546325554'),
(5, 'GUANTI SATINATO DPL NR=20', '99546325554'),
(6, 'secchi', '99546325554'),
(7, 'SAPONE MANI DERMOMED NR=5', '26971442321'),
(8, 'SANITEC LAVAPIATTI NR=5LT', '26971442321'),
(9, 'lenzuola', '87896521463'),
(10, 'tovaglia', '87896521463'),
(11, 'lavavetri', '38544768294'),
(12, 'scopa', '99546325554'),
(13, 'PROSCIUTTO CRUDO DISSOS. ', '19632587456'),
(14, 'OLIO EXTRA VERGINE OLIVA ', '00125498351'),
(15, 'PANCETTA STUFATA', '00125498351'),
(16, 'UOVA BRICCO KG 1', '00125498351'),
(17, 'FARINA 00 KG 1', '00125498351'),
(18, 'FORMAGGIO GRANA  GRATTUGI', '00125498351'),
(19, 'MELONE NR=CASSETTA DA 12', '24698315789'),
(20, 'CAROTA NR=CASSETTA DA 160', '24698315789'),
(21, 'AGLIO NR=23 TESTE', '24698315789'),
(22, 'CIPOLLE BIANCHE NR=CASSET', '24698315789'),
(23, 'FUNGHI CHIODINI GR 800', '00125498351'),
(24, 'VITELLO SPALLA GELO', '00125498351'),
(25, 'VINO BIANCO LT 1 NR=LT 1', '11445236974'),
(26, 'GELATO COPPA ORO GUSTI MI', '22556487621'),
(27, 'DOLCE TIRAMISU TONDO PRET', '00125498351'),
(28, 'CAROTE RONDELLE GELO KG 2', '00125498351'),
(29, 'BRODO PREPARATO GRANULI K', '88882563941'),
(30, 'CREMA DI RISO PRECOTTA GR', '00125498351'),
(31, 'BIETA ERBETTA GELO KG 2,5', '00125498351'),
(32, 'POLPA POMODORO KG 10 NR=K', '88882563941'),
(33, 'PEPE NERO MACINATO NR=1 V', '00125498351'),
(34, 'CAPPERI ACETO VASO KG 0,7', '00125498351'),
(35, 'PREZZEMOLO SURGELATO KG 1', '00125498351'),
(36, 'PESCE BACCALA'' WM 60/80', '00125498351'),
(37, 'PASTA D''ACCIUGHE KG 1 NR=', '00125498351'),
(38, 'BASILICO GELO KG 1 NR=KG ', '00125498351'),
(39, 'PINOLI NR=GR 500', '24698315789'),
(40, 'RADICCHIO DI TREVISO NR=C', '24698315789'),
(41, 'LIMONE SUCCO BOTTIGLIA LT', '00125498351'),
(42, 'RISO CARNAROLI KG 5 NR=KG', '00125498351'),
(43, 'VINO ROSSO LT 1/4 NR=1 BO', '11445236974'),
(44, 'ROSMARINO NR=MAZZETTO GR1', '24698315789'),
(45, 'SUINO SPALLA FRESCA', '00125498351'),
(46, 'VINO BIANCO LT 1/4 NR=1 B', '00125498351'),
(47, 'SALVIA NR=GR100', '24698315789');

-- --------------------------------------------------------

--
-- Struttura della tabella `alimento`
--
CREATE TABLE `alimento` (
	`codiceAli` varchar(15) NOT NULL PRIMARY KEY,
	`nomeAli` varchar(50) NOT NULL,
	`TMC` date DEFAULT NULL,
	`dataProdConf` date DEFAULT NULL,
	`dataScad` date DEFAULT NULL,
	`deperibile` tinyint(1) NOT NULL,
	`quantitaAli` int(11) NOT NULL,
	`unitaMisura` enum('KG','NR','LT','GR') DEFAULT NULL,
	`numeroCella` int(11) DEFAULT NULL,
	`partitaLotto` varchar(15) DEFAULT NULL,
	`pianoStanza` varchar(5) NOT NULL,
	`codiceArtOrd` int(11) NOT NULL,
	FOREIGN KEY (`numeroCella`) REFERENCES `cella` (`numeroCella`),
	FOREIGN KEY (`pianoStanza`) REFERENCES `stanzadimagazzino` (`pianoStanza`),
	FOREIGN KEY (`codiceArtOrd`) REFERENCES `articoloordinabile` (`codiceArtOrd`)
);
--
-- Dump dei dati per la tabella `alimento`
--
INSERT INTO `alimento` (`codiceAli`, `nomeAli`, `TMC`, `dataProdConf`, `dataScad`, `deperibile`, `quantitaAli`, `unitaMisura`, `numeroCella`, `partitaLotto`, `pianoStanza`, `codiceArtOrd`) VALUES
('A0001', 'LATTE UHT P.S. LT 1 NR=1LT', NULL, '2017-10-05', '2017-10-12', 1, 30, 'LT', 3, '224545', '001', 1),
('A0002', 'PROSCIUTTO CRUDO DISSOS. PARMA 16-18 MESI A KG', NULL, NULL, '2018-03-25', 1, 5, 'KG', 1, '896542', '001', 13),
('A0003', 'OLIO EXTRA VERGINE OLIVA LT 5 NR=5LT', NULL, '2017-10-01', '2018-10-25', 1, 10, 'NR', 3, '985632', '001', 14),
('A0004', 'PANCETTA STUFATA', '2018-02-25', NULL, NULL, 1, 6, 'KG', 1, '45896', '001', 15),
('A0005', 'UOVA BRICCO KG 1', NULL, NULL, '2018-04-14', 0, 40, 'KG', NULL, '85463', '001', 16),
('A0006', 'FARINA 00 KG 1', NULL, NULL, '2018-08-13', 0, 25, 'KG', NULL, '78965', '002', 17),
('A0007', 'FORMAGGIO GRANA  GRATTUGIATO NR=1KG', NULL, NULL, NULL, 0, 5, 'NR', NULL, '45632', '002', 18),
('A0008', 'PASTA DI SEMOLA KG 5', NULL, NULL, '2018-09-12', 0, 20, 'NR', NULL, '156897', '001', 2),
('A0009', 'MELONE NR=CASSETTA DA 12', NULL, NULL, '2018-04-26', 1, 8, 'NR', 2, '896321', '001', 19),
('A0010', 'CAROTA NR=CASSETTA DA 160', NULL, NULL, '2019-01-25', 1, 5, 'NR', 2, '632145', '001', 20),
('A0011', 'AGLIO NR=23 TESTE', NULL, NULL, NULL, 0, 10, 'NR', NULL, '45789', '002', 21),
('A0012', 'CIPOLLE BIANCHE NR=CASSETTA DA 120', NULL, NULL, NULL, 0, 8, 'NR', NULL, '63157', '002', 22),
('A0013', 'FUNGHI CHIODINI GR 800', NULL, NULL, '2018-06-08', 0, 10, 'NR', NULL, '29873', '002', 23),
('A0014', 'VITELLO SPALLA GELO', '2018-12-31', NULL, NULL, 1, 25, 'KG', 4, '52196', '001', 24),
('A0015', 'VINO BIANCO LT 1 NR=LT 1', NULL, NULL, '2019-02-09', 0, 30, 'NR', NULL, '149637', '002', 25),
('A0017', 'GELATO COPPA ORO GUSTI MISTI GR 85 NR=GR 85', NULL, NULL, '2018-09-25', 1, 150, 'NR', 4, '452176', '001', 26),
('A0018', 'DOLCE TIRAMISU TONDO PRET. GELO', NULL, NULL, '2018-09-16', 1, 50, 'NR', 4, '521968', '001', 27),
('A0019', 'CAROTE RONDELLE GELO KG 2,5', NULL, NULL, '2018-06-05', 1, 25, 'NR', 4, '732645', '001', 28),
('A0020', 'BRODO PREPARATO GRANULI KG 1', NULL, NULL, '2018-05-06', 0, 10, 'NR', NULL, NULL, '001', 29),
('A0021', 'CREMA DI RISO PRECOTTA GR 220 NR=GR 220', NULL, NULL, '2018-04-15', 0, 25, 'NR', NULL, '9631452', '002', 30),
('A0022', 'BURRO KG 1', NULL, NULL, '2018-01-15', 1, 25, 'KG', 3, '856321', '001', 3),
('A0023', 'BIETA ERBETTA GELO KG 2,5', NULL, NULL, '2018-03-09', 1, 50, 'NR', 4, '934862', '001', 31),
('A0024', 'POLPA POMODORO KG 10 NR=KG 10', NULL, NULL, '2018-07-26', 0, 20, 'NR', NULL, '198642', '002', 32),
('A0026', 'PEPE NERO MACINATO NR=1 VASO GR 400', '2019-11-29', NULL, NULL, 0, 8, 'NR', NULL, '521639', '002', 33),
('A0027', 'CAPPERI ACETO VASO KG 0,72 NR=KG 0,72', NULL, NULL, '2018-08-29', 0, 20, 'NR', NULL, '8931455', '002', 34),
('A0028', 'PREZZEMOLO SURGELATO KG 1 NR=KG 1', NULL, NULL, '2018-08-19', 1, 6, 'NR', 4, '164328', '001', 35),
('A0029', 'PESCE BACCALA'' WM 60/80', NULL, NULL, '2018-09-11', 0, 15, 'KG', NULL, '4631987', '002', 36),
('A0030', 'PASTA D''ACCIUGHE KG 1 NR=KG 1', NULL, NULL, '2018-05-22', 0, 5, 'NR', NULL, '1269745', '002', 37),
('A0031', 'BASILICO GELO KG 1 NR=KG 1', NULL, NULL, '2018-04-26', 1, 5, 'NR', 4, '6492138', '001', 38),
('A0032', 'PINOLI NR=GR 500', NULL, NULL, '2018-06-05', 0, 18, 'NR', NULL, '641966', '002', 39),
('A0033', 'RADICCHIO DI TREVISO NR=CASSETTA DA 7', NULL, NULL, '2018-02-25', 1, 10, 'NR', 2, '63195422', '001', 40),
('A0034', 'LIMONE SUCCO BOTTIGLIA LT 1', NULL, NULL, '2018-06-22', 0, 15, 'LT', NULL, '5541269', '002', 41),
('A0035', 'RISO CARNAROLI KG 5 NR=KG 5', NULL, NULL, '2018-05-09', 0, 30, 'NR', NULL, '941558', '002', 42),
('A0036', 'VINO ROSSO LT 1/4 NR=1 BOTT 1/4', NULL, NULL, '2018-05-16', 0, 25, 'NR', NULL, NULL, '002', 43),
('A0037', 'ROSMARINO NR=MAZZETTO GR100', '2018-02-16', NULL, NULL, 0, 30, 'NR', NULL, '5599746', '002', 44),
('A0038', 'SUINO SPALLA FRESCA', '2018-02-22', NULL, NULL, 1, 10, 'KG', 1, '559744', '001', 45),
('A0039', 'VINO BIANCO LT 1/4 NR=1 BOTT 1/4', NULL, NULL, '2018-07-11', 0, 15, 'NR', NULL, '6641398', '002', 46),
('A0040', 'SALVIA NR=GR100', '2018-04-25', NULL, NULL, 0, 20, 'NR', NULL, '994215', '002', 47);

--
-- Trigger `alimento`
--
DELIMITER //
CREATE TRIGGER `autoAlimento` BEFORE INSERT ON `alimento`
FOR EACH ROW 
BEGIN 
	SET @num=(SELECT sCounter FROM contatori WHERE tipo='alimenti');
    SET @num=@num+1;
    UPDATE contatori SET sCounter=@num WHERE tipo='alimenti';
    SET NEW.codiceAli = concat('A',REPEAT('0',4-LENGTH(@num)), @num);
END//

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `articolomag`
--

CREATE TABLE `articolomag` (
	`codiceArtMag` varchar(15) NOT NULL PRIMARY KEY,
	`nomeArt` varchar(50) NOT NULL,
	`quantitaArt` int(11) NOT NULL,
	`unitaMisura` enum('KG','NR','LT','GR') DEFAULT NULL,
	`tipoArt` enum('generici','detersivi','teleria') NOT NULL,
	`partitaLotto` varchar(15) DEFAULT NULL,
	`pianoStanza` varchar(5) NOT NULL,
	`codiceArtOrd` int(11) NOT NULL,
	FOREIGN KEY (`pianoStanza`) REFERENCES `stanzadimagazzino` (`pianoStanza`),
	FOREIGN KEY (`codiceArtOrd`) REFERENCES `articoloordinabile` (`codiceArtOrd`)
);

--
-- Dump dei dati per la tabella `articolomag`
--

INSERT INTO `articolomag` (`codiceArtMag`, `nomeArt`, `quantitaArt`, `unitaMisura`, `tipoArt`, `partitaLotto`, `pianoStanza`, `codiceArtOrd`) VALUES
('D0001', 'SAPONE MANI DERMOMED NR=5LT', 10, 'LT', 'detersivi', '665874', '003', 7),
('D0002', 'SANITEC LAVAPIATTI NR=5LT', 6, 'LT', 'detersivi', '562398', '003', 8),
('D0003', 'LAVAVETRI', 25, '', 'detersivi', '8888', '003', 11),
('G0001', 'SPUGNA VILEDA NR=5', 10, '', 'generici', '225635', '004', 4),
('G0002', 'GUANTI SATINATO DPL NR=20 PAIA', 15, '', 'generici', '221456', '004', 5),
('G0003', 'SECCHIO', 6, '', 'generici', '886321', '101', 6),
('G0004', 'SCOPA', 10, '', 'generici', '45689', '101', 12),
('T0001', 'LENZUOLA', 30, '', 'teleria', '201568', '201', 9),
('T0002', 'TOVAGLIA', 20, '', 'teleria', '523197', '201', 10);

--
-- Trigger `articolomag`
--
DELIMITER //
CREATE TRIGGER `autoArticolo` BEFORE INSERT ON `articolomag`
FOR EACH ROW 
BEGIN 
	SET @num = ( 
		SELECT sCounter 
		FROM contatori 
		WHERE tipo = new.tipoArt 
	); 
	SET @num = @num + 1; 
	UPDATE contatori SET sCounter = @num WHERE tipo = new.tipoArt; 
	SET NEW.codiceArtMag = concat(UPPER(LEFT(new.tipoArt, 1)), REPEAT('0', 4 - LENGTH(@num)), @num);
END//

DELIMITER ;

-- --------------------------------------------------------



--
-- Struttura della tabella `categoria`
--

CREATE TABLE `categoria` (
	`nomeCat` varchar(15) NOT NULL PRIMARY KEY,
	`codiceMgznr` int(11) NOT NULL,
	FOREIGN KEY (`codiceMgznr`) REFERENCES `personale`(`codicePers`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `categoria`
--

INSERT INTO `categoria` (`nomeCat`, `codiceMgznr`) VALUES
('generici', 13),
('alimenti', 14),
('detersivi', 15),
('teleria', 16);

-- --------------------------------------------------------

--
-- Struttura della tabella `contatori`
--

CREATE TABLE `contatori` (
	`sCounter` int(11) NOT NULL,
	`tipo` enum('alimenti','generici','detersivi','teleria','antipasto','primo','secondo','contorno','dessert') NOT NULL PRIMARY KEY
);

--
-- Dump dei dati per la tabella `contatori`
--

INSERT INTO `contatori` (`sCounter`, `tipo`) VALUES
(44, 'alimenti'),
(6, 'generici'),
(3, 'detersivi'),
(3, 'teleria'),
(1, 'antipasto'),
(4, 'primo'),
(3, 'secondo'),
(2, 'contorno'),
(1, 'dessert');

-- --------------------------------------------------------

--
-- Struttura della tabella `ricetta`
--

CREATE TABLE `ricetta` (
	`codiceRicetta` varchar(15) NOT NULL PRIMARY KEY,
	`portata` enum('antipasto','primo','secondo','contorno','dessert') NOT NULL,
	`nomeRicetta` varchar(50) NOT NULL,
	`procedimento` mediumtext,
	`codiceCapocuoco` int(11) NOT NULL DEFAULT '5',
	`numPersone` int(11) NOT NULL DEFAULT '1',
	FOREIGN KEY (`codiceCapocuoco`) REFERENCES `personale` (`codicePers`)
);

--
-- Dump dei dati per la tabella `ricetta`
--

INSERT INTO `ricetta` (`codiceRicetta`, `portata`, `nomeRicetta`, `procedimento`, `codiceCapocuoco`, `numPersone`) VALUES
('A0001', 'antipasto', 'PROSCIUTTO CRUDO E MELONE', NULL, 5, 1),
('C0001', 'contorno', 'CAROTE TRIFOLATE', NULL, 5, 1),
('C0002', 'contorno', 'BIETA ERBETTA', NULL, 5, 1),
('P0001', 'primo', 'SPAGHETTI ALLA CARBONARA', NULL, 5, 1),
('P0002', 'primo', 'ASCIUTTA ALL''AMATRICINA', NULL, 5, 1),
('P0003', 'primo', 'PENNE AL PESTO GENOVESE', NULL, 5, 1),
('P0004', 'primo', 'RISOTTO AL RADICCHIO DI TREVISO', NULL, 5, 1),
('S0001', 'secondo', 'ARROSTO VITELLO AI CHIODINI', NULL, 5, 1),
('S0002', 'secondo', 'BACCALA'' ALLA VICENTINA', "Lasciare il baccalà in acqua per 3 giorni (cambiando l'acqua 2 volte al giorno). Spinare il baccalà da crudo e metterlo a sgocciolare per circa 2 ore. Tritata la cipolla, il prezzemolo, l'aglio e i capperi, aggiungere la pasta di acciughe, mettere il tutto in un contenitore e mescolare bene. Cospargere il fondo di una placca da forno con olio, cominciare ad adagiare il baccalà (salando poco), aggiungere una manciata di farina, una spruzzata di parmigiano, un abbondante cucchiaio di trito, preparato prima, cospargendo bene tutto il baccalà che verrà in fine irrorato con olio e poco latte.
Allo stesso modo si procede con il secondo e il terzo strato di baccalà (si consiglia di non superare i tre strati di baccalà per una buona cottura, scegliendo una teglia abbastanza capiente).
Infine se avanziamo olio e latte lo verseremo sul baccalà.
IMPORTANTE la cottura al forno non deve superare mai i 130° e deve protrarsi per 5-6 ore.", 5, 1),
('S0003', 'secondo', 'ARROSTO DI MAIALE', NULL, 5, 1);

--
-- Trigger `ricetta`
--
DELIMITER //
CREATE TRIGGER `autoRicetta` BEFORE INSERT ON `ricetta`
FOR EACH ROW 
BEGIN
	SET @num=(
		SELECT sCounter 
		FROM contatori 
		WHERE tipo=new.portata
	);
    SET @num=@num+1;
    UPDATE contatori SET sCounter=@num WHERE tipo=new.portata;
    SET NEW.codiceRicetta = concat(UPPER(LEFT(new.portata, 1)),REPEAT('0',4-LENGTH(@num)), @num);
END//

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `ingrediente`
--

CREATE TABLE `ingrediente` (
	`codiceIng` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`codiceRicetta` varchar(15) NOT NULL,
	`codiceAli` varchar(15) NOT NULL,
	`quantitaIng` decimal(10,2) NOT NULL,
	`unitaMisura` enum('KG','NR','LT','GR') DEFAULT 'GR',
	FOREIGN KEY (`codiceRicetta`) REFERENCES `ricetta` (`codiceRicetta`),
	FOREIGN KEY (`codiceAli`) REFERENCES `alimento` (`codiceAli`)
);

--
-- Dump dei dati per la tabella `ingrediente`
--

INSERT INTO `ingrediente` (`codiceIng`, `codiceRicetta`, `codiceAli`, `quantitaIng`, `unitaMisura`) VALUES
(1, 'P0001', 'A0008', '60.00', 'GR'),
(2, 'P0001', 'A0004', '15.00', 'GR'),
(3, 'P0001', 'A0005', '20.00', 'GR'),
(4, 'P0001', 'A0006', '5.00', 'GR'),
(5, 'P0001', 'A0007', '10.00', 'GR'),
(6, 'P0001', 'A0001', '70.00', 'GR'),
(7, 'P0001', 'A0003', '10.00', 'GR'),
(8, 'A0001', 'A0002', '70.00', 'GR'),
(9, 'A0001', 'A0009', '200.00', 'GR'),
(10, 'S0001', 'A0010', '5.00', 'GR'),
(11, 'S0001', 'A0011', '2.00', 'GR'),
(12, 'S0001', 'A0013', '10.00', 'GR'),
(13, 'S0001', 'A0012', '2.00', 'GR'),
(14, 'S0001', 'A0015', '10.00', 'GR'),
(15, 'S0001', 'A0014', '130.00', 'GR'),
(16, 'S0001', 'A0003', '5.00', 'GR'),
(17, 'C0001', 'A0019', '150.00', 'GR'),
(18, 'C0001', 'A0003', '5.00', 'GR'),
(19, 'C0001', 'A0020', '1.00', 'GR'),
(20, 'C0001', 'A0021', '3.00', 'GR'),
(21, 'C0001', 'A0022', '2.00', 'GR'),
(22, 'C0002', 'A0023', '230.00', 'GR'),
(23, 'C0002', 'A0003', '10.00', 'GR'),
(24, 'C0002', 'A0020', '1.00', 'GR'),
(25, 'P0002', 'A0008', '65.00', 'GR'),
(26, 'P0002', 'A0004', '15.00', 'GR'),
(27, 'P0002', 'A0012', '20.00', 'GR'),
(28, 'P0002', 'A0024', '40.00', 'GR'),
(29, 'P0002', 'A0003', '5.00', 'GR'),
(30, 'P0002', 'A0026', '2.00', 'GR'),
(40, 'S0002', 'A0029', '50.00', 'GR'),
(41, 'S0002', 'A0027', '1.00', 'GR'),
(42, 'S0002', 'A0001', '80.00', 'GR'),
(43, 'S0002', 'A0030', '1.00', 'GR'),
(44, 'S0002', 'A0012', '10.00', 'GR'),
(45, 'S0002', 'A0003', '30.00', 'GR'),
(46, 'S0002', 'A0007', '5.00', 'GR'),
(47, 'S0002', 'A0028', '3.00', 'GR'),
(48, 'P0003', 'A0031', '20.00', 'GR'),
(49, 'P0003', 'A0008', '60.00', 'GR'),
(50, 'P0003', 'A0032', '3.00', 'GR'),
(51, 'P0003', 'A0003', '20.00', 'GR'),
(52, 'P0003', 'A0007', '10.00', 'GR'),
(53, 'P0003', 'A0022', '5.00', 'GR'),
(54, 'P0004', 'A0033', '35.00', 'GR'),
(55, 'P0004', 'A0012', '10.00', 'GR'),
(56, 'P0004', 'A0034', '2.00', 'GR'),
(57, 'P0004', 'A0035', '60.00', 'GR'),
(58, 'P0004', 'A0036', '5.00', 'GR'),
(59, 'P0004', 'A0007', '10.00', 'GR'),
(60, 'P0004', 'A0020', '5.00', 'GR'),
(61, 'P0004', 'A0022', '8.00', 'GR'),
(62, 'S0003', 'A0011', '2.00', 'GR'),
(63, 'S0003', 'A0039', '9.00', 'GR'),
(64, 'S0003', 'A0003', '10.00', 'GR'),
(65, 'S0003', 'A0040', '0.50', 'GR'),
(66, 'S0003', 'A0037', '1.00', 'GR'),
(67, 'S0003', 'A0038', '130.00', 'GR');

-- --------------------------------------------------------

--
-- Struttura della tabella `ordinazione`
--

CREATE TABLE `ordinazione` (
`codiceOrd` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
`codiceMgznr` int(11) NOT NULL,
`codiceArtOrd` int(11) NOT NULL,
`nomeArt` varchar(50) NOT NULL,
`dataOrd` date NOT NULL,
`quantitaOrd` int(11) NOT NULL,
`unitaMisura` enum('KG','NR','LT','GR') DEFAULT NULL,
FOREIGN KEY (`codiceMgznr`) REFERENCES `personale` (`codicePers`),
FOREIGN KEY (`codiceArtOrd`) REFERENCES `articoloordinabile` (`codiceArtOrd`)
);

--
-- Dump dei dati per la tabella `ordinazione`
--

INSERT INTO `ordinazione` (`codiceOrd`, `codiceMgznr`, `codiceArtOrd`, `nomeArt`, `dataOrd`, `quantitaOrd`, `unitaMisura`) VALUES
(1, 14, 1, 'LATTE UHT P.S. LT 1 NR=1LT', '2017-09-03', 80, 'NR'),
(2, 14, 2, 'PASTA DI SEMOLA KG 5', '2017-02-15', 30, 'NR'),
(3, 14, 3, 'BURRO KG 1', '2017-09-17', 25, 'NR'),
(4, 13, 4, 'spugne', '2017-10-12', 15, 'NR'),
(5, 13, 5, 'GUANTI SATINATO DPL NR=20 PAIA', '2017-10-09', 2, 'NR'),
(6, 13, 6, 'secchi', '2017-10-15', 10, 'NR'),
(7, 15, 7, 'SAPONE MANI DERMOMED NR=5LT', '2017-10-12', 6, 'NR'),
(8, 15, 8, 'SANITEC LAVAPIATTI NR=5LT', '2017-10-09', 10, 'NR'),
(9, 16, 9, 'lenzuola', '2017-10-20', 45, 'NR'),
(10, 16, 10, 'TOVAGLIA', '2017-10-21', 30, 'NR'),
(11, 15, 11, 'LAVAVETRI', '2018-02-16', 8, 'NR');

-- --------------------------------------------------------

--
-- Struttura della tabella `richiestaalimento`
--

CREATE TABLE `richiestaalimento` (
`codiceRic` int(11) NOT NULL PRIMARY KEY,
`codicePers` int(11) NOT NULL,
`codiceAli` varchar(15) NOT NULL,
`nomeArt` varchar(50) NOT NULL,
`dataRic` date NOT NULL,
`quantitaRic` int(11) NOT NULL,
`unitaMisura` enum('KG','NR','LT','GR') DEFAULT NULL,
FOREIGN KEY (`codiceAli`) REFERENCES `alimento` (`codiceAli`),
FOREIGN KEY (`codicePers`) REFERENCES `personale` (`codicePers`) 
);

--
-- Dump dei dati per la tabella `richiestaalimento`
--

INSERT INTO `richiestaalimento` (`codiceRic`, `codicePers`, `codiceAli`, `nomeArt`, `dataRic`, `quantitaRic`, `unitaMisura`) VALUES
('4', 2, 'A0022', 'BURRO KG 1', '2018-07-18', 4, 'KG'),
('5', 1, 'A0001', 'LATTE UHT P.S. LT 1 NR=1LT', '2018-11-14', 15, 'LT'),
('6', 3, 'A0010', 'CAROTA NR=CASSETTA DA 160', '2018-09-29', 10, 'NR'),
('8', 4, 'A0015', 'VINO BIANCO LT 1 NR=LT 1', '2018-10-12', 6, 'NR'),
('9', 5, 'A0023', 'BIETA ERBETTA GELO KG 2,5', '2018-09-26', 25, 'NR');

--
-- Trigger `richiestaalimento`
--
DELIMITER //
CREATE TRIGGER `autoRichiestaAli` BEFORE INSERT ON `richiestaalimento`
FOR EACH ROW 
BEGIN 
	SET @numTot =(
		SELECT COUNT(*) 
		FROM ( 
			SELECT codiceRic
			FROM richiestaalimento
			UNION ALL
			SELECT codiceRic
			FROM richiestaartmag
		) AS unione
	); 
	SET @numTot = @numTot + 1; 
	SET new.codiceRic = @numTot;
	-- trigger controlloQuantita
	SELECT a.quantitaAli, a.unitaMisura INTO @q, @u FROM alimento a
    WHERE a.codiceAli=new.codiceAli;
	IF(@u=new.unitaMisura)
    THEN 
		IF(@q < new.quantitaRic)
    	THEN
        	SIGNAL SQLSTATE VALUE '45000' 
        	SET MESSAGE_TEXT = "La quantita' richiesta e' superiore alla giacenza in magazzino";
   		END IF;
    ELSE 
		IF(@u <> '') THEN 
			SET @message = CONCAT("L'unita' di misura da inserire deve essere: ", @u); 
			SIGNAL SQLSTATE VALUE '45000'
			SET MESSAGE_TEXT = @message; 
		ELSE 
			SIGNAL SQLSTATE VALUE '45000' 
			SET MESSAGE_TEXT = "L'unita' di misura non e' stata specificata in magazzino, lasciare il campo vuoto (se c'e' levare la spunta da NULL)"; 
		END IF;
	END IF;
END//

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `richiestaartmag`
--

CREATE TABLE `richiestaartmag` (
	`codiceRic` int(11) NOT NULL PRIMARY KEY,
	`codicePers` int(11) NOT NULL,
	`codiceArtMag` varchar(15) NOT NULL,
	`nomeArt` varchar(50) NOT NULL,
	`dataRic` date NOT NULL,
	`quantitaRic` int(11) NOT NULL,
	`unitaMisura` enum('KG','NR','LT','GR') DEFAULT NULL,
	FOREIGN KEY (`codiceArtMag`) REFERENCES `articolomag` (`codiceArtMag`),
	FOREIGN KEY (`codicePers`) REFERENCES `personale` (`codicePers`) 
);

--
-- Dump dei dati per la tabella `richiestaartmag`
--

INSERT INTO `richiestaartmag` (`codiceRic`, `codicePers`, `codiceArtMag`, `nomeArt`, `dataRic`, `quantitaRic`, `unitaMisura`) VALUES
(1, 10, 'G0002', 'GUANTI SATINATO DPL NR=20 PAIA', '2017-12-12', 10, 'NR'),
(2, 10, 'T0001', 'lenzuola', '2017-03-29', 9, 'NR'),
(3, 2, 'D0001', 'SAPONE MANI DERMOMED NR=5LT', '2018-01-11', 1, 'LT'),
(7, 2, 'G0003', 'secchio', '2018-10-10', 5, ''),
(10, 11, 'D0001', 'SAPONE MANI DERMOMED NR=5LT', '2018-01-17', 8, 'LT'),
(11, 5, 'D0003', 'LAVAVETRI', '2017-10-09', 6, '');

--
-- Trigger `richiestaartmag`
--
DELIMITER //
CREATE TRIGGER `autoRichiestaArt` BEFORE INSERT ON `richiestaartmag`
FOR EACH ROW 
BEGIN 
	SET @numTot =(
		SELECT COUNT(*) 
		FROM ( 
			SELECT codiceRic
			FROM richiestaalimento
			UNION ALL
			SELECT codiceRic
			FROM richiestaartmag
		) AS unione
	); 
	SET @numTot = @numTot + 1; 
	SET new.codiceRic = @numTot;
	-- trigger controlloQuantita
	SELECT a.quantitaArt, a.unitaMisura INTO @q, @u 
	FROM articolomag a
    WHERE a.codiceArtMag=new.codiceArtMag;
	IF(@u=new.unitaMisura)
    THEN 
		IF(@q<new.quantitaRic)
    	THEN
        	SIGNAL SQLSTATE VALUE '45000' 
        	SET MESSAGE_TEXT = "La quantita' richiesta e' superiore alla giacenza in magazzino";
   		 END IF;
    ELSE 
		IF(@u <> '') THEN 
			SET @message = CONCAT("L'unita' di misura da inserire deve essere: ", @u); 
			SIGNAL SQLSTATE VALUE '45000'
			SET MESSAGE_TEXT = @message; 
		ELSE 
			SIGNAL SQLSTATE VALUE '45000'
			SET MESSAGE_TEXT = "L'unita' di misura non e' stata specificata in magazzino, lasciare il campo vuoto (se c'e' levare la spunta da NULL)";
		END IF; 
	END IF;
END//

DELIMITER ;

--
--	Query...
-- 
-- --------------------------------------------------------
--
-- Query1
--
-- Query che ritorni il codice e il nome di tutti gli articoli 
-- in magazzino di tipo detersivo con le denominazioni dei relativi 
-- fornitori e con la quantità ordinata che dev’essere maggiore di 5 NR.
--
CREATE VIEW Query1 AS
	SELECT ao.codiceArtOrd, am.codiceArtMag, am.nomeArt, o.quantitaOrd, f.denominazione, f.pIva 
	FROM articoloordinabile ao 
	JOIN ordinazione o ON (o.codiceArtOrd = ao.codiceArtOrd) 
	JOIN fornitore f ON (f.pIva = ao.pIvaFornitore) 
	JOIN articoloMag am ON (am.codiceArtOrd = ao.codiceArtOrd) 
	WHERE o.quantitaOrd > 5 AND o.unitaMisura = 'NR' 
	AND am.tipoArt = "detersivi";
	
-- --------------------------------------------------------
	
--
-- Query2
--
-- Query che ritorni l’e-mail dei fornitori che non hanno mai partecipato 
-- ad ordinazioni eseguite dal magazziniere della categoria alimentari
--
CREATE VIEW Query2 AS
	SELECT email 
	FROM fornitore 
	WHERE pIva NOT IN ( 
		SELECT ao.pIvaFornitore 
		FROM ordinazione o 
		JOIN articoloordinabile ao ON o.codiceArtOrd = ao.codiceArtOrd 
		WHERE o.codiceMgznr = ( 
			SELECT codicePers 
			FROM personale p 
			JOIN categoria c ON p.codicePers = c.CodiceMgznr 
			WHERE p.ruolo = "magazziniere" AND c.nomeCat = "alimenti" 
		) 
	);
	
-- --------------------------------------------------------
	
--
-- Query3
--
-- Query che ritorni nome e cognome dei membri del personale che hanno fatto 
-- una richiesta al magazziniere Giovanni Storti nell’autunno di quest’anno, 
-- specificando il nome dell’articolo richiesto
--

CREATE VIEW Query3_richieste AS
	SELECT nomeArt, codicePers, codiceAli AS codiceArt, dataRic 
	FROM richiestaalimento 
	UNION ALL
	SELECT nomeArt, codicePers, codiceArtMag AS codiceArt, dataRic 
	FROM richiestaartmag;
    
    
CREATE VIEW Query3_articoli AS   
	SELECT codiceAli AS codiceArt, pianoStanza 
	FROM `alimento` 
	UNION ALL
	SELECT codiceArtMag AS codiceArt, pianoStanza 
	FROM articolomag;
    
CREATE VIEW Query3 AS
	SELECT p.nome, p.cognome, r.nomeArt 
	FROM personale p 
	JOIN Query3_richieste r ON (p.codicePers = r.codicePers) 
	JOIN Query3_articoli art ON (r.codiceArt = art.codiceArt) 
	JOIN stanzadimagazzino s ON (s.pianoStanza = art.pianoStanza) 
	WHERE r.dataRic 
	BETWEEN concat(YEAR(CURDATE()), '-09-23') AND concat(YEAR(CURDATE()), '-12-21') 
	AND s.codiceMgznr = ( 
		SELECT codicePers 
		FROM personale 
		WHERE nome = 'giovanni' AND cognome = 'storti' 
	)ORDER BY p.nome, p.cognome;

-- --------------------------------------------------------
	
--
-- Query4
--
-- Query che restituisca il nome delle ricette che hanno ingredienti 
-- riferiti ad alimenti che sono scaduti nella cella dei formaggi
--
CREATE VIEW Query4 AS
	SELECT r.nomeRicetta, a.nomeAli AS Scaduto 
	FROM ricetta r 
	JOIN ingrediente i ON (r.codiceRicetta = i.codiceRicetta) 
	JOIN alimento a ON(i.codiceAli = a.codiceAli) 
		WHERE dataScad < CURDATE() AND numeroCella = ( 
		SELECT numeroCella 
		FROM cella 
		WHERE tipoCella = 'formaggi'
	);

-- --------------------------------------------------------
	
--
-- Query5
--
-- Query che ritorni la media del numero di richieste effettuate negli ultimi 30 giorni
--

CREATE VIEW Query5_richieste AS
    SELECT nomeArt, codicePers, codiceAli AS codiceArt, dataRic 
    FROM richiestaalimento 
    UNION ALL
    SELECT nomeArt, codicePers, codiceArtMag AS codiceArt, dataRic 
    FROM richiestaartmag;
    
CREATE VIEW Query5_numRicUlt30 AS 
    SELECT COUNT(*) AS num 
    FROM Query5_richieste AS r 
    WHERE r.dataRic BETWEEN (CURDATE() - INTERVAL 1 MONTH ) AND CURDATE(); 

CREATE VIEW Query5 AS
	SELECT num / 30 AS richiesteMedieUltimi30gg 
	FROM Query5_numRicUlt30;

-- --------------------------------------------------------
	
--
-- Query6
--
-- Query che restituisca il nome del magazziniere che gestisce 
-- più articoli tenendo conto anche degli alimenti
--

CREATE VIEW Query6_conteggio AS 
	SELECT COUNT(*) numeroArt, c.nomeCat, p.nome, p.cognome 
	FROM personale p, stanzadimagazzino s, articolomag a, categoria c
	WHERE s.codiceMgznr = p.codicePers AND c.nomeCat = 'detersivi' 
	AND s.pianoStanza = a.pianoStanza AND p.codicePers = c.codiceMgznr 
	UNION ALL
	SELECT COUNT(*) numeroArt, c.nomeCat, p.nome, p.cognome 
	FROM personale p, stanzadimagazzino s, articolomag a, categoria c
	WHERE s.codiceMgznr = p.codicePers AND c.nomeCat = 'teleria' 
	AND s.pianoStanza = a.pianoStanza AND p.codicePers = c.codiceMgznr
	UNION ALL
	SELECT COUNT(*) numeroArt, c.nomeCat, p.nome, p.cognome 
	FROM personale p, stanzadimagazzino s, articolomag a, categoria c
	WHERE s.codiceMgznr = p.codicePers AND c.nomeCat = 'generici' 
	AND s.pianoStanza = a.pianoStanza AND p.codicePers = c.codiceMgznr
	UNION ALL
	SELECT COUNT(*) numeroArt, c.nomeCat, p.nome, p.cognome
	FROM personale p, stanzadimagazzino s, alimento a, categoria c 
	WHERE s.codiceMgznr = p.codicePers AND c.nomeCat = 'alimenti' 
	AND s.pianoStanza = a.pianoStanza AND p.codicePers = c.codiceMgznr; 

CREATE VIEW Query6 AS
	SELECT nome, cognome 
	FROM Query6_conteggio 
	WHERE numeroArt = ( 
		SELECT MAX(numeroArt) 
		FROM Query6_conteggio 
	) ;
	
-- --------------------------------------------------------

