-- SPDX-License-Identifier: MIT
-- OAI DB dump - slices organized in classic SQL blocks
-- Compatible with MySQL 5.7 style imports used by OAI charts.
--
-- HOW TO ADD A NEW SLICE:
-- 1) Copy one full block:
--      AUTHENTICATION - SLICE X
--      SESSION MANAGEMENT - SLICE X
-- 2) Choose a new IMSI range, for example:
--      SST 4 / DNN oai4 -> 001010000000400 to 001010000000420
-- 3) Change:
--      SST, DNN, IP subnet, 5QI, AMBR UL/DL
--
-- Current organization:
--   SLICE 1: SST 1 / SD FFFFFF / DNN oai  / UEs 001010000000100-120 / subnet 12.1.1.0/24
--   SLICE 2: SST 2 / SD FFFFFF / DNN oai2 / UEs 001010000000200-220 / subnet 12.1.2.0/24
--   SLICE 3: SST 3 / SD FFFFFF / DNN oai3 / UEs 001010000000300-320 / subnet 12.1.3.0/24
--
-- IMPORTANT:
-- This file keeps "sd": "FFFFFF" because your working file used it.
-- Make sure AMF / NSSF / SMF / UPF / UE use the same S-NSSAI format.
-- If your runtime config uses only "sst" without "sd", remove the sd field everywhere.

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

CREATE TABLE `AccessAndMobilitySubscriptionData` (
  `ueid` varchar(15) NOT NULL,
  `servingPlmnid` varchar(15) NOT NULL,
  `supportedFeatures` varchar(50) DEFAULT NULL,
  `gpsis` json DEFAULT NULL,
  `internalGroupIds` json DEFAULT NULL,
  `sharedVnGroupDataIds` json DEFAULT NULL,
  `subscribedUeAmbr` json DEFAULT NULL,
  `nssai` json DEFAULT NULL,
  `ratRestrictions` json DEFAULT NULL,
  `forbiddenAreas` json DEFAULT NULL,
  `serviceAreaRestriction` json DEFAULT NULL,
  `coreNetworkTypeRestrictions` json DEFAULT NULL,
  `rfspIndex` int(10) DEFAULT NULL,
  `subsRegTimer` int(10) DEFAULT NULL,
  `ueUsageType` int(10) DEFAULT NULL,
  `mpsPriority` tinyint(1) DEFAULT NULL,
  `mcsPriority` tinyint(1) DEFAULT NULL,
  `activeTime` int(10) DEFAULT NULL,
  `sorInfo` json DEFAULT NULL,
  `sorInfoExpectInd` tinyint(1) DEFAULT NULL,
  `sorafRetrieval` tinyint(1) DEFAULT NULL,
  `sorUpdateIndicatorList` json DEFAULT NULL,
  `upuInfo` json DEFAULT NULL,
  `micoAllowed` tinyint(1) DEFAULT NULL,
  `sharedAmDataIds` json DEFAULT NULL,
  `odbPacketServices` json DEFAULT NULL,
  `serviceGapTime` int(10) DEFAULT NULL,
  `mdtUserConsent` json DEFAULT NULL,
  `mdtConfiguration` json DEFAULT NULL,
  `traceData` json DEFAULT NULL,
  `cagData` json DEFAULT NULL,
  `stnSr` varchar(50) DEFAULT NULL,
  `cMsisdn` varchar(50) DEFAULT NULL,
  `nbIoTUePriority` int(10) DEFAULT NULL,
  `nssaiInclusionAllowed` tinyint(1) DEFAULT NULL,
  `rgWirelineCharacteristics` varchar(50) DEFAULT NULL,
  `ecRestrictionDataWb` json DEFAULT NULL,
  `ecRestrictionDataNb` tinyint(1) DEFAULT NULL,
  `expectedUeBehaviourList` json DEFAULT NULL,
  `primaryRatRestrictions` json DEFAULT NULL,
  `secondaryRatRestrictions` json DEFAULT NULL,
  `edrxParametersList` json DEFAULT NULL,
  `ptwParametersList` json DEFAULT NULL,
  `iabOperationAllowed` tinyint(1) DEFAULT NULL,
  `wirelineForbiddenAreas` json DEFAULT NULL,
  `wirelineServiceAreaRestriction` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Amf3GppAccessRegistration` (
  `ueid` varchar(15) NOT NULL,
  `amfInstanceId` varchar(50) NOT NULL,
  `supportedFeatures` varchar(50) DEFAULT NULL,
  `purgeFlag` tinyint(1) DEFAULT NULL,
  `pei` varchar(50) DEFAULT NULL,
  `imsVoPs` json DEFAULT NULL,
  `deregCallbackUri` varchar(50) NOT NULL,
  `amfServiceNameDereg` json DEFAULT NULL,
  `pcscfRestorationCallbackUri` varchar(50) DEFAULT NULL,
  `amfServiceNamePcscfRest` json DEFAULT NULL,
  `initialRegistrationInd` tinyint(1) DEFAULT NULL,
  `guami` json NOT NULL,
  `backupAmfInfo` json DEFAULT NULL,
  `drFlag` tinyint(1) DEFAULT NULL,
  `ratType` json NOT NULL,
  `urrpIndicator` tinyint(1) DEFAULT NULL,
  `amfEeSubscriptionId` varchar(50) DEFAULT NULL,
  `epsInterworkingInfo` json DEFAULT NULL,
  `ueSrvccCapability` tinyint(1) DEFAULT NULL,
  `registrationTime` varchar(50) DEFAULT NULL,
  `vgmlcAddress` json DEFAULT NULL,
  `contextInfo` json DEFAULT NULL,
  `noEeSubscriptionInd` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `AuthenticationStatus` (
  `ueid` varchar(20) NOT NULL,
  `nfInstanceId` varchar(50) NOT NULL,
  `success` tinyint(1) NOT NULL,
  `timeStamp` varchar(50) NOT NULL,
  `authType` varchar(25) NOT NULL,
  `servingNetworkName` varchar(50) NOT NULL,
  `authRemovalInd` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `AuthenticationSubscription` (
  `ueid` varchar(20) NOT NULL,
  `authenticationMethod` varchar(25) NOT NULL,
  `encPermanentKey` varchar(50) DEFAULT NULL,
  `protectionParameterId` varchar(50) DEFAULT NULL,
  `sequenceNumber` json DEFAULT NULL,
  `authenticationManagementField` varchar(50) DEFAULT NULL,
  `algorithmId` varchar(50) DEFAULT NULL,
  `encOpcKey` varchar(50) DEFAULT NULL,
  `encTopcKey` varchar(50) DEFAULT NULL,
  `vectorGenerationInHss` tinyint(1) DEFAULT NULL,
  `n5gcAuthMethod` varchar(15) DEFAULT NULL,
  `rgAuthenticationInd` tinyint(1) DEFAULT NULL,
  `supi` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `SdmSubscriptions` (
  `ueid` varchar(15) NOT NULL,
  `subsId` int(10) UNSIGNED NOT NULL,
  `nfInstanceId` varchar(50) NOT NULL,
  `implicitUnsubscribe` tinyint(1) DEFAULT NULL,
  `expires` varchar(50) DEFAULT NULL,
  `callbackReference` varchar(50) NOT NULL,
  `amfServiceName` json DEFAULT NULL,
  `monitoredResourceUris` json NOT NULL,
  `singleNssai` json DEFAULT NULL,
  `dnn` varchar(50) DEFAULT NULL,
  `subscriptionId` varchar(50) DEFAULT NULL,
  `plmnId` json DEFAULT NULL,
  `immediateReport` tinyint(1) DEFAULT NULL,
  `report` json DEFAULT NULL,
  `supportedFeatures` varchar(50) DEFAULT NULL,
  `contextInfo` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `SessionManagementSubscriptionData` (
  `ueid` varchar(15) NOT NULL,
  `servingPlmnid` varchar(15) NOT NULL,
  `singleNssai` json NOT NULL,
  `dnnConfigurations` json DEFAULT NULL,
  `internalGroupIds` json DEFAULT NULL,
  `sharedVnGroupDataIds` json DEFAULT NULL,
  `sharedDnnConfigurationsId` varchar(50) DEFAULT NULL,
  `odbPacketServices` json DEFAULT NULL,
  `traceData` json DEFAULT NULL,
  `sharedTraceDataId` varchar(50) DEFAULT NULL,
  `expectedUeBehavioursList` json DEFAULT NULL,
  `suggestedPacketNumDlList` json DEFAULT NULL,
  `3gppChargingCharacteristics` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `SmfRegistrations` (
  `ueid` varchar(15) NOT NULL,
  `subpduSessionId` int(10) NOT NULL,
  `smfInstanceId` varchar(50) NOT NULL,
  `smfSetId` varchar(50) DEFAULT NULL,
  `supportedFeatures` varchar(50) DEFAULT NULL,
  `pduSessionId` int(10) NOT NULL,
  `singleNssai` json NOT NULL,
  `dnn` varchar(50) DEFAULT NULL,
  `emergencyServices` tinyint(1) DEFAULT NULL,
  `pcscfRestorationCallbackUri` varchar(50) DEFAULT NULL,
  `plmnId` json NOT NULL,
  `pgwFqdn` varchar(50) DEFAULT NULL,
  `epdgInd` tinyint(1) DEFAULT NULL,
  `deregCallbackUri` varchar(50) DEFAULT NULL,
  `registrationReason` json DEFAULT NULL,
  `registrationTime` varchar(50) DEFAULT NULL,
  `contextInfo` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `SmfSelectionSubscriptionData` (
  `ueid` varchar(15) NOT NULL,
  `servingPlmnid` varchar(15) NOT NULL,
  `supportedFeatures` varchar(50) DEFAULT NULL,
  `subscribedSnssaiInfos` json DEFAULT NULL,
  `sharedSnssaiInfosId` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `AccessAndMobilitySubscriptionData`
  ADD PRIMARY KEY (`ueid`,`servingPlmnid`) USING BTREE;

ALTER TABLE `Amf3GppAccessRegistration`
  ADD PRIMARY KEY (`ueid`);

ALTER TABLE `AuthenticationStatus`
  ADD PRIMARY KEY (`ueid`);

ALTER TABLE `AuthenticationSubscription`
  ADD PRIMARY KEY (`ueid`);

ALTER TABLE `SdmSubscriptions`
  ADD PRIMARY KEY (`subsId`,`ueid`) USING BTREE;

ALTER TABLE `SessionManagementSubscriptionData`
  ADD PRIMARY KEY (`ueid`,`servingPlmnid`) USING BTREE;

ALTER TABLE `SmfRegistrations`
  ADD PRIMARY KEY (`ueid`,`subpduSessionId`) USING BTREE;

ALTER TABLE `SmfSelectionSubscriptionData`
  ADD PRIMARY KEY (`ueid`,`servingPlmnid`) USING BTREE;


-- =====================================================================
-- AUTHENTICATION - SLICE 1 - SST 1 - DNN oai - original UE range
-- =====================================================================

INSERT INTO `AuthenticationSubscription` (`ueid`, `authenticationMethod`, `encPermanentKey`, `protectionParameterId`, `sequenceNumber`, `authenticationManagementField`, `algorithmId`, `encOpcKey`, `encTopcKey`, `vectorGenerationInHss`, `n5gcAuthMethod`, `rgAuthenticationInd`, `supi`) VALUES
('001010000000100', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000100'),
('001010000000101', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000101'),
('001010000000102', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000102'),
('001010000000103', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000103'),
('001010000000104', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000104'),
('001010000000105', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000105'),
('001010000000106', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000106'),
('001010000000107', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000107'),
('001010000000108', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000108'),
('001010000000109', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000109'),
('001010000000110', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000110'),
('001010000000111', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000111'),
('001010000000112', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000112'),
('001010000000113', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000113'),
('001010000000114', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000114'),
('001010000000115', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000115'),
('001010000000116', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000116'),
('001010000000117', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000117'),
('001010000000118', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000118'),
('001010000000119', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000119'),
('001010000000120', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000120');

-- =====================================================================
-- SESSION MANAGEMENT - SLICE 1 - SST 1 / SD FFFFFF / DNN oai
-- UEs 001010000000100-120
-- =====================================================================

INSERT INTO `SessionManagementSubscriptionData` (`ueid`, `servingPlmnid`, `singleNssai`, `dnnConfigurations`) VALUES
('001010000000100', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":1,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":15},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.100\"}]},\"ims\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4V6\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"}}}'),
('001010000000101', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":1,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":15},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.101\"}]},\"ims\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4V6\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"}}}'),
('001010000000102', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":1,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":15},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.102\"}]},\"ims\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4V6\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"}}}'),
('001010000000103', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":1,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":15},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.103\"}]},\"ims\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4V6\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"}}}'),
('001010000000104', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":1,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":15},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.104\"}]},\"ims\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4V6\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"}}}'),
('001010000000105', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":1,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":15},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.105\"}]},\"ims\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4V6\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":15,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"}}}'),
('001010000000106', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.106\"}]}}'),
('001010000000107', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.107\"}]}}'),
('001010000000108', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.108\"}]}}'),
('001010000000109', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.109\"}]}}'),
('001010000000110', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.110\"}]}}'),
('001010000000111', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.111\"}]}}'),
('001010000000112', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.112\"}]}}'),
('001010000000113', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.113\"}]}}'),
('001010000000114', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.114\"}]}}'),
('001010000000115', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.115\"}]}}'),
('001010000000116', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.116\"}]}}'),
('001010000000117', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.117\"}]}}'),
('001010000000118', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.118\"}]}}'),
('001010000000119', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.119\"}]}}'),
('001010000000120', '00101', '{\"sst\": 1, \"sd\": \"FFFFFF\"}', '{\"oai\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":6,\"arp\":{\"priorityLevel\":1,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"NOT_PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\",\"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.1.120\"}]}}');

-- =====================================================================
-- AUTHENTICATION - SLICE 2 - SST 2 - DNN oai2 - added UE range
-- =====================================================================

INSERT INTO `AuthenticationSubscription` (`ueid`, `authenticationMethod`, `encPermanentKey`, `protectionParameterId`, `sequenceNumber`, `authenticationManagementField`, `algorithmId`, `encOpcKey`, `encTopcKey`, `vectorGenerationInHss`, `n5gcAuthMethod`, `rgAuthenticationInd`, `supi`) VALUES
('001010000000200', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000200'),
('001010000000201', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000201'),
('001010000000202', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000202'),
('001010000000203', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000203'),
('001010000000204', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000204'),
('001010000000205', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000205'),
('001010000000206', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000206'),
('001010000000207', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000207'),
('001010000000208', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000208'),
('001010000000209', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000209'),
('001010000000210', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000210'),
('001010000000211', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000211'),
('001010000000212', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000212'),
('001010000000213', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000213'),
('001010000000214', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000214'),
('001010000000215', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000215'),
('001010000000216', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000216'),
('001010000000217', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000217'),
('001010000000218', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000218'),
('001010000000219', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000219'),
('001010000000220', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000220');

-- =====================================================================
-- SESSION MANAGEMENT - SLICE 2 - SST 2 / SD FFFFFF / DNN oai2
-- UEs 001010000000200-220
-- =====================================================================

INSERT INTO `SessionManagementSubscriptionData` (`ueid`, `servingPlmnid`, `singleNssai`, `dnnConfigurations`) VALUES
('001010000000200', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.100\"}]}}'),
('001010000000201', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.101\"}]}}'),
('001010000000202', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.102\"}]}}'),
('001010000000203', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.103\"}]}}'),
('001010000000204', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.104\"}]}}'),
('001010000000205', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.105\"}]}}'),
('001010000000206', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.106\"}]}}'),
('001010000000207', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.107\"}]}}'),
('001010000000208', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.108\"}]}}'),
('001010000000209', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.109\"}]}}'),
('001010000000210', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.110\"}]}}'),
('001010000000211', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.111\"}]}}'),
('001010000000212', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.112\"}]}}'),
('001010000000213', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.113\"}]}}'),
('001010000000214', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.114\"}]}}'),
('001010000000215', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.115\"}]}}'),
('001010000000216', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.116\"}]}}'),
('001010000000217', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.117\"}]}}'),
('001010000000218', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.118\"}]}}'),
('001010000000219', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.119\"}]}}'),
('001010000000220', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai2\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":2,\"arp\":{\"priorityLevel\":5,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":5},\"sessionAmbr\":{\"uplink\":\"50Mbps\",\"downlink\":\"100Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.2.120\"}]}}');

-- =====================================================================
-- AUTHENTICATION - SLICE 3 - SST 3 - DNN oai3 - added UE range
-- =====================================================================

INSERT INTO `AuthenticationSubscription` (`ueid`, `authenticationMethod`, `encPermanentKey`, `protectionParameterId`, `sequenceNumber`, `authenticationManagementField`, `algorithmId`, `encOpcKey`, `encTopcKey`, `vectorGenerationInHss`, `n5gcAuthMethod`, `rgAuthenticationInd`, `supi`) VALUES
('001010000000300', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000300'),
('001010000000301', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000301'),
('001010000000302', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000302'),
('001010000000303', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000303'),
('001010000000304', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000304'),
('001010000000305', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000305'),
('001010000000306', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000306'),
('001010000000307', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000307'),
('001010000000308', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000308'),
('001010000000309', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000309'),
('001010000000310', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000310'),
('001010000000311', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000311'),
('001010000000312', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000312'),
('001010000000313', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000313'),
('001010000000314', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000314'),
('001010000000315', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000315'),
('001010000000316', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000316'),
('001010000000317', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000317'),
('001010000000318', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000318'),
('001010000000319', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000319'),
('001010000000320', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000320');

-- =====================================================================
-- SESSION MANAGEMENT - SLICE 3 - SST 3 / SD FFFFFF / DNN oai3
-- UEs 001010000000300-320
-- =====================================================================

INSERT INTO `SessionManagementSubscriptionData` (`ueid`, `servingPlmnid`, `singleNssai`, `dnnConfigurations`) VALUES
('001010000000300', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.100\"}]}}'),
('001010000000301', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.101\"}]}}'),
('001010000000302', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.102\"}]}}'),
('001010000000303', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.103\"}]}}'),
('001010000000304', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.104\"}]}}'),
('001010000000305', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.105\"}]}}'),
('001010000000306', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.106\"}]}}'),
('001010000000307', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.107\"}]}}'),
('001010000000308', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.108\"}]}}'),
('001010000000309', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.109\"}]}}'),
('001010000000310', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.110\"}]}}'),
('001010000000311', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.111\"}]}}'),
('001010000000312', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.112\"}]}}'),
('001010000000313', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.113\"}]}}'),
('001010000000314', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.114\"}]}}'),
('001010000000315', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.115\"}]}}'),
('001010000000316', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.116\"}]}}'),
('001010000000317', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.117\"}]}}'),
('001010000000318', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.118\"}]}}'),
('001010000000319', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.119\"}]}}'),
('001010000000320', '00101', '{\"sst\": 3, \"sd\": \"FFFFFF\"}', '{\"oai3\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":7,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.3.120\"}]}}');

-- =====================================================================
-- AUTHENTICATION - SLICE 4 - SST 4 - DNN oai4 - added UE range
-- =====================================================================

INSERT INTO `AuthenticationSubscription` (`ueid`, `authenticationMethod`, `encPermanentKey`, `protectionParameterId`, `sequenceNumber`, `authenticationManagementField`, `algorithmId`, `encOpcKey`, `encTopcKey`, `vectorGenerationInHss`, `n5gcAuthMethod`, `rgAuthenticationInd`, `supi`) VALUES
('001010000000400', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000400'),
('001010000000401', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000401'),
('001010000000402', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000402'),
('001010000000403', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000403'),
('001010000000404', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000404'),
('001010000000405', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000405'),
('001010000000406', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000406'),
('001010000000407', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000407'),
('001010000000408', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000408'),
('001010000000409', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000409'),
('001010000000410', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000410'),
('001010000000411', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000411'),
('001010000000412', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000412'),
('001010000000413', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000413'),
('001010000000414', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000414'),
('001010000000415', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000415'),
('001010000000416', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000416'),
('001010000000417', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000417'),
('001010000000418', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000418'),
('001010000000419', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000419'),
('001010000000420', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000420');

-- =====================================================================
-- SESSION MANAGEMENT - SLICE 4 - SST 2 / SD FFFFFF / DNN oai4
-- UEs 001010000000400-420
-- =====================================================================

INSERT INTO `SessionManagementSubscriptionData` (`ueid`, `servingPlmnid`, `singleNssai`, `dnnConfigurations`) VALUES
('001010000000400', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.100\"}]}}'),
('001010000000401', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.101\"}]}}'),
('001010000000402', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.102\"}]}}'),
('001010000000403', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.103\"}]}}'),
('001010000000404', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.104\"}]}}'),
('001010000000405', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.105\"}]}}'),
('001010000000406', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.106\"}]}}'),
('001010000000407', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.107\"}]}}'),
('001010000000408', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.108\"}]}}'),
('001010000000409', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.109\"}]}}'),
('001010000000410', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.110\"}]}}'),
('001010000000411', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.111\"}]}}'),
('001010000000412', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.112\"}]}}'),
('001010000000413', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.113\"}]}}'),
('001010000000414', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.114\"}]}}'),
('001010000000415', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.115\"}]}}'),
('001010000000416', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.116\"}]}}'),
('001010000000417', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.117\"}]}}'),
('001010000000418', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.118\"}]}}'),
('001010000000419', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.119\"}]}}'),
('001010000000420', '00101', '{\"sst\": 2, \"sd\": \"FFFFFF\"}', '{\"oai4\":{\"pduSessionTypes\":{\"defaultSessionType\":\"IPV4\"},\"sscModes\":{\"defaultSscMode\":\"SSC_MODE_1\"},\"5gQosProfile\":{\"5qi\":9,\"arp\":{\"priorityLevel\":10,\"preemptCap\":\"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":10},\"sessionAmbr\":{\"uplink\":\"20Mbps\",\"downlink\":\"50Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\":\"12.1.4.120\"}]}}');

-- =====================================================================
-- TEMPLATE POUR AJOUTER UN NOUVEAU SLICE, EXEMPLE SLICE 4
--
-- Ce fichier évite volontairement les PROCEDURE, DELIMITER, TEMP TABLE.
-- Pour ajouter SST 4 / DNN oai4:
--   - copie le bloc AUTHENTICATION d'un slice existant
--   - remplace 200-220 par 400-420
--   - copie le bloc SESSION MANAGEMENT d'un slice existant
--   - remplace:
--       sst: 4
--       dnn: oai4
--       IP: 12.1.4.100-120
--       5QI / AMBR selon le besoin
-- =====================================================================


ALTER TABLE `SdmSubscriptions`
  MODIFY `subsId` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
