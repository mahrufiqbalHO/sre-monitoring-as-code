local defaultMetricTypes = import 'metric-types.libsonnet';

local customMetricTypes = if std.extVar('CUSTOM_METRIC_TYPES') == 'true' then import '../mixin-defs/custom-metric-types.libsonnet' else {};

// This file is for storing the config of the MaC framework

// MaC prefix
local macPrefix = 'SRE MaC';

// MaC dashboard title and uid prefix
local macDashboardPrefix = {
  title: macPrefix,
  uid: std.strReplace(std.asciiLower(macPrefix), ' ', '-'),
};

// Config items
// Collection of imports for detail dashboard elements
local detailDashboardElements = {
  httpRequestsAvailability: (import 'dashboards/detail-dashboard-elements/http-requests-availability.libsonnet'),
  httpRequestsLatency: (import 'dashboards/detail-dashboard-elements/http-requests-latency.libsonnet'),
  cloudwatchSqs: (import 'dashboards/detail-dashboard-elements/cloudwatch-sqs.libsonnet'),
  customMetric: (import 'dashboards/detail-dashboard-elements/custom-metric.libsonnet'),
};

// The list of error budget burn rate windows used for alerts
local burnRateWindowList = [
  { severity: '1', 'for': '2m', long: '1h', short: '5m', factor: 14.4 },
  { severity: '2', 'for': '2m', long: '6h', short: '30m', factor: 6 },
  { severity: '4', 'for': '3h', long: '3d', short: '6h', factor: 1 },
];

// The template for error budget burn rule names
local burnRateRuleNameTemplate = 'slo_burnrate:%s';

// The localhost urls for alerts
local localhostUrls = {
  grafana: 'http://localhost:3000',
  alertmanager: 'http://localhost:9093',
};

// The keys are the labels in the alert payload, the values are either the static value as a string,
// a string reference to the variable name or a mix of both
local alertPayloadTemplate = {
  source_instance: 'Prometheus',
  node_id: '%(config.applicationServiceName)s',
  resource_id: '%(config.applicationServiceName)s',
  event_short_desc: '%(sliSpec.title)s',
  event_description: '%(sliKey)s (%(journeyKey)s journey) is likely to exhaust error budget in less than %(exhaustionDays).2f days',
  metric_name: '%(sliSpec.sliType)s',
  event_type: '%(sliSpec.sliType)s',
  message_key: 'Prometheus_%(config.applicationServiceName)s_%(sliSpec.sliType)s_%(config.applicationServiceName)s',
  event_severity: '%(severity)s',
  raw_event_payload: '"journey":"%(journeyKey)s","sli":"%(sliKey)s","mac_version":"%(config.macVersion)s","monitoring_slackchannel":"%(config.alertingSlackChannel)s","configuration_item":"%(configurationItem)s"',
  assignment_group: '%(config.servicenowAssignmentGroup)s',
  runbook_id: '%(runbookUrl)s',
};

// File exports
{
  macPrefix: macPrefix,
  macDashboardPrefix: macDashboardPrefix,
  metricTypes: defaultMetricTypes + customMetricTypes,
  detailDashboardElements: detailDashboardElements,
  burnRateWindowList: burnRateWindowList,
  burnRateRuleNameTemplate: burnRateRuleNameTemplate,
  localhostUrls: localhostUrls,
  alertPayloadTemplate: alertPayloadTemplate,
}
