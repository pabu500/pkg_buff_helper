import 'dart:ui';

import 'package:flutter/material.dart';

enum MeterOps {
  None,
  CPC,
  Bypass,
  SetConc,
  SetSite,
  SetConcTariff,
  Replacement,
  DetachSn,
  AttachSn,
  ReadingDataInsert,
  SetLcStatus,
}

enum CreditOps {
  None,
  Topup,
  Reset,
}

enum UserOps {
  None,
  EnableDisable,
}

enum ListItemType {
  Meter,
  Credit,
  User,
  Concentrator,
}

enum ItemOpLifecycleStatus {
  cip,
  normal,
  maint,
  decommissioned,
  bypassed,
}

ItemOpLifecycleStatus getItemOpLifecycleStatus(String? statusStr) {
  if (statusStr == null || statusStr.isEmpty) {
    return ItemOpLifecycleStatus.normal;
  }
  if (statusStr == '-') {
    return ItemOpLifecycleStatus.normal;
  }
  switch (statusStr) {
    case 'cip' || 'commission in progress':
      return ItemOpLifecycleStatus.cip;
    case 'normal':
      return ItemOpLifecycleStatus.normal;
    case 'maint' || 'maintenance':
      return ItemOpLifecycleStatus.maint;
    case 'dc' || 'decommissioned':
      return ItemOpLifecycleStatus.decommissioned;
    case 'byp' || 'bypassed':
      return ItemOpLifecycleStatus.bypassed;
    default:
      return ItemOpLifecycleStatus.normal;
  }
}

String? getLcStatusTagStr(String? statusStr) {
  if ((statusStr ?? '').isEmpty) {
    return null;
  }
  ItemOpLifecycleStatus? status = getItemOpLifecycleStatus(statusStr);

  return lcStatusInfo[status]!['tag'];
}

String getOpLifecycleStatusMessage(String? statusStr) {
  if (statusStr == null) {
    return 'N/A';
  }
  ItemOpLifecycleStatus? status =
      ItemOpLifecycleStatus.values.byName(statusStr);

  return lcStatusInfo[status]!['tooltip'];
}

Color getOpLifecycleStatusColor(String? statusStr) {
  if (statusStr == null || statusStr.isEmpty) {
    return Colors.transparent;
  }
  ItemOpLifecycleStatus? status =
      ItemOpLifecycleStatus.values.byName(statusStr);

  return lcStatusInfo[status]!['color'];
}

final Map<ItemOpLifecycleStatus, dynamic> lcStatusInfo = {
  ItemOpLifecycleStatus.cip: {
    'tag': 'CIP',
    'color': Colors.lime.shade800,
    'tooltip': 'Commission in Progress',
  },
  ItemOpLifecycleStatus.normal: {
    'tag': 'Normal',
    'color': Colors.green,
    'tooltip': 'Normal',
  },
  ItemOpLifecycleStatus.maint: {
    'tag': 'Maint.',
    'color': Colors.orangeAccent.withOpacity(0.5),
    'tooltip': 'Under Maintenance',
  },
  ItemOpLifecycleStatus.decommissioned: {
    'tag': 'DC',
    'color': Colors.brown,
    'tooltip': 'Decommissioned',
  },
  ItemOpLifecycleStatus.bypassed: {
    'tag': 'Byp',
    'color': Colors.grey.shade500,
    'tooltip': 'Bypassed',
  },
};

Map<String, dynamic> getLcStatusTag(row, fieldKey) {
  if ((row['lc_status'] ?? '').isEmpty) {
    return {};
  }
  if (row['lc_status'] == '-') {
    return {};
  }
  String valueStr = row['lc_status'].toString().toLowerCase();
  ItemOpLifecycleStatus? status = getItemOpLifecycleStatus(valueStr);
  if (status == ItemOpLifecycleStatus.normal) {
    return {};
  }

  if (fieldKey == 'first_reading_val' || fieldKey == 'last_reading_val') {
    return {
      'tag': '-',
      'color': Colors.transparent,
      'tooltip': '',
    };
  }

  return {
    'tag': getLcStatusTagStr(valueStr),
    'color': getOpLifecycleStatusColor(status.name),
    'tooltip': getOpLifecycleStatusMessage(status.name),
  };
}

const topUpMax = 100;
const topUpMin = 0.01;
const resetMax = 100;
const resetMin = -100;

String? validatorTopup(String? value) {
  value = value ?? '';
  value = value.trim();
  // if (value.isEmpty) {
  //   return 'Please enter a valid number';
  // }
  if (double.tryParse(value) == null) {
    return 'Please enter a valid number';
  }
  //between 0.01 and 100
  if (double.parse(value) < 0.01 || double.parse(value) > 100) {
    return 'Please enter a number between 0.01 and 100';
  }
  return null;
}

String? validatorReset(String? value) {
  value = value ?? '';
  value = value.trim();
  // if (value.isEmpty) {
  //   return 'Please enter a valid number';
  // }
  if (double.tryParse(value) == null) {
    return 'Please enter a valid number';
  }
  if (double.parse(value) < -100 || double.parse(value) > 100) {
    return 'Please enter a number between -100 and 100';
  }
  return null;
}

String? validateTariffPrice(String? value) {
  value = value ?? '';
  value = value.trim();
  // if (value.isEmpty) {
  //   return 'Please enter a valid number';
  // }
  if (double.tryParse(value) == null) {
    return 'invalid number';
  }
  if (double.parse(value) < 0) {
    return 'min 0';
  }
  //max 50
  if (double.parse(value) > 50) {
    return 'max 50';
  }
  return null;
}
