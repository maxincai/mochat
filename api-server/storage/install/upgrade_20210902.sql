CREATE TABLE IF NOT EXISTS `mc_contact_batch_add_allot` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `import_id` int(11) NOT NULL DEFAULT '0' COMMENT '客户账号表ID',
  `employee_id` int(11) NOT NULL DEFAULT '0' COMMENT '跟进员工ID',
  `type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态 0回收 1分配',
  `operate_id` int(11) NOT NULL DEFAULT '0' COMMENT '操作人ID（如果有）',
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id_type_index` (`employee_id`,`type`) COMMENT '统计索引'
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='批量新增客户分配记录表';

CREATE TABLE IF NOT EXISTS `mc_contact_batch_add_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `corp_id` int(11) NOT NULL DEFAULT '0' COMMENT '企业ID',
  `pending_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '待处理客户提醒开关 0关 1开',
  `pending_time_out` int(11) NOT NULL DEFAULT '0' COMMENT '待处理客户提醒超时天数',
  `pending_reminder_time` time NOT NULL DEFAULT '00:00:00' COMMENT '待处理客户提醒时间',
  `pending_leader_id` int(11) NOT NULL DEFAULT '0' COMMENT '通知管理员ID',
  `undone_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '成员未添加客户提醒开关 0关 1开',
  `undone_time_out` int(11) NOT NULL DEFAULT '0' COMMENT '成员未添加客户提醒超时天数',
  `undone_reminder_time` time NOT NULL DEFAULT '00:00:00' COMMENT '成员未添加客户提醒时间',
  `recycle_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '回收客户开关 0关 1开',
  `recycle_time_out` int(11) NOT NULL DEFAULT '0' COMMENT '客户超过天数回收',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='批量新增客户配置表';

CREATE TABLE IF NOT EXISTS `mc_contact_batch_add_import` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `corp_id` int(11) NOT NULL DEFAULT '0' COMMENT '企业ID（冗余）',
  `record_id` int(11) NOT NULL DEFAULT '0' COMMENT '导入记录ID',
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '客户手机号',
  `upload_at` timestamp NULL DEFAULT NULL COMMENT '导入时间',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '添加状态 0待分配 1待添加 2待通过 3已添加',
  `add_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '添加时间',
  `employee_id` int(11) NOT NULL DEFAULT '0' COMMENT '分配员工',
  `allot_num` int(11) NOT NULL DEFAULT '0' COMMENT '分配次数',
  `remark` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '备注',
  `tags` json NOT NULL COMMENT '添加成功后标签',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id,status_index` (`employee_id`,`status`) COMMENT '统计索引'
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='批量新增客户账号表';

CREATE TABLE IF NOT EXISTS `mc_contact_batch_add_import_record` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `corp_id` int(11) NOT NULL DEFAULT '0' COMMENT '企业ID',
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '导入任务名称',
  `upload_at` timestamp NULL DEFAULT NULL COMMENT '上传时间',
  `allot_employee` json NOT NULL COMMENT '分配客服',
  `tags` json NOT NULL COMMENT '客户标签',
  `import_num` int(11) NOT NULL DEFAULT '0' COMMENT '导入客户数量',
  `add_num` int(11) NOT NULL DEFAULT '0' COMMENT '已添加客户数',
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '上传文件名',
  `file_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '上传文件地址',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='批量新增客户导入记录表';

CREATE TABLE IF NOT EXISTS `mc_contact_message_batch_send` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `corp_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业表ID （mc_corp.id）',
  `user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '用户ID【mc_user.id】',
  `user_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '用户名称【mc_user.name】',
  `filter_params` json DEFAULT NULL COMMENT '筛选客户参数',
  `filter_params_detail` json DEFAULT NULL COMMENT '筛选客户参数显示详情',
  `content` json NOT NULL COMMENT '群发消息内容',
  `send_way` tinyint(4) NOT NULL DEFAULT '1' COMMENT '发送方式（1-立即发送，2-定时发送）',
  `definite_time` timestamp NULL DEFAULT NULL COMMENT '定时发送时间',
  `send_time` timestamp NULL DEFAULT NULL COMMENT '发送时间',
  `send_employee_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送成员数量',
  `send_contact_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送客户数量',
  `send_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '已发送数量',
  `not_send_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '未发送数量',
  `received_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '已送达数量',
  `not_received_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '未送达数量',
  `receive_limit_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '客户接收已达上限',
  `not_friend_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '因不是好友发送失败',
  `send_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态（0-未发送，1-已发送）',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客户消息群发表';

CREATE TABLE IF NOT EXISTS `mc_contact_message_batch_send_employee` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `batch_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '客户消息群发id （mc_contact_message_batch_send.id)',
  `employee_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '员工id （mc_work_employee.id)',
  `wx_user_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '微信userId （mc_work_employee.wx_user_id)',
  `send_contact_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送客户数量',
  `content` json NOT NULL COMMENT '群发消息内容',
  `err_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT '返回码',
  `err_msg` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '对返回码的文本描述内容',
  `msg_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '企业群发消息的id，可用于获取群发消息发送结果',
  `send_time` timestamp NULL DEFAULT NULL COMMENT '发送时间',
  `last_sync_time` timestamp NULL DEFAULT NULL COMMENT '最后一次同步结果时间',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态（0-未发送，1-已发送, 2-发送失败）',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客户消息群发成员表';

CREATE TABLE IF NOT EXISTS `mc_contact_message_batch_send_result` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `batch_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '客户消息群发id （mc_contact_message_batch_send.id)',
  `employee_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '员工id （mc_work_employee.id)',
  `contact_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '客户表id（work_contact.id）',
  `external_user_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '外部联系人userid',
  `user_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '企业服务人员的userid',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '发送状态 0-未发送 1-已发送 2-因客户不是好友导致发送失败 3-因客户已经收到其他群发消息导致发送失败',
  `send_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送时间，发送状态为1时返回',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客户消息群发结果表';

CREATE TABLE IF NOT EXISTS `mc_room_message_batch_send` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `corp_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '企业表ID （mc_corp.id）',
  `user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '用户ID【mc_user.id】',
  `user_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '用户名称【mc_user.name】',
  `batch_title` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '群发名称',
  `content` json NOT NULL COMMENT '群发消息内容',
  `send_way` tinyint(4) NOT NULL DEFAULT '1' COMMENT '发送方式（1-立即发送，2-定时发送）',
  `definite_time` timestamp NULL DEFAULT NULL COMMENT '定时发送时间',
  `send_time` timestamp NULL DEFAULT NULL COMMENT '发送时间',
  `send_room_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送成员数量',
  `send_contact_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送客户数量',
  `send_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '已发送数量',
  `not_send_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '未发送数量',
  `received_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '已送达数量',
  `not_received_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '未送达数量',
  `send_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态（0-未发送，1-已发送）',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客户群消息群发表';

CREATE TABLE IF NOT EXISTS `mc_room_message_batch_send_employee` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `batch_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '客户群消息群发id （mc_contact_message_batch_send.id)',
  `employee_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '员工id （mc_work_employee.id)',
  `wx_user_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '微信userId （mc_work_employee.wx_user_id)',
  `send_room_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送群数量',
  `content` json NOT NULL COMMENT '群发消息内容',
  `err_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT '返回码',
  `err_msg` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '对返回码的文本描述内容',
  `msg_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '企业群发消息的id，可用于获取群发消息发送结果',
  `send_time` timestamp NULL DEFAULT NULL COMMENT '发送时间',
  `last_sync_time` timestamp NULL DEFAULT NULL COMMENT '最后一次同步结果时间',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态（0-未发送，1-已发送, 2-发送失败）',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客户群消息群发成员表';

CREATE TABLE IF NOT EXISTS `mc_room_message_batch_send_result` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `batch_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '客户群消息群发id （mc_contact_message_batch_send.id)',
  `employee_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '员工id （mc_work_employee.id)',
  `room_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '客户群id（work_room.id）',
  `room_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '客户群名称（work_room.name）',
  `room_employee_num` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '客户群成员数量',
  `room_create_time` timestamp NULL DEFAULT NULL COMMENT '群聊创建时间',
  `chat_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '外部客户群id，群发消息到客户不吐出该字段',
  `user_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '企业服务人员的userid',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '发送状态 0-未发送 1-已发送 2-因客户不是好友导致发送失败 3-因客户已经收到其他群发消息导致发送失败',
  `send_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发送时间，发送状态为1时返回',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客户群消息群发结果表';
