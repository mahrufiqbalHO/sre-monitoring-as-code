// This file is for generating the journey dashboards which show information for each SLI in the
// journey

// Grafana imports
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local template = grafana.template;

// MaC imports
local macConfig = import '../mac-config.libsonnet';
local stringFormattingFunctions = import '../util/string-formatting-functions.libsonnet';

// Create the Grafana panels grouping all SLI types under a single SLI panel
// @param slis A map of SLIs keyed by the SLI type
// @returns array of panel elements
local createPanelInfo(slis) =

  local row = 0;
  local findSli(elem, slis) = slis[std.objectFields(slis)[elem]];
  [
    // Status panel indicating SLO performance over last reporting period (30d by default)
    [findSli(elem, slis).slo_availability_panel { gridPos: { x: 0, y: elem * row, w: 4, h: 6 } }]
    +
    // Graph panel showing remaining error budget for reportinhg period (30d by default) over
    // selectable number of days
    [findSli(elem, slis).error_budget_panel { gridPos: { x: 4, y: elem * row, w: 10, h: 6 } }]
    +
    // Transparent text panel added to make spacing for slo status panel correct
    [grafana.text.new(title=null, transparent=true) + { gridPos: { x: 14, y: elem * row, w: 0.5, h: 1 } }]
    +
    // Status of SLO (pass/fail) for same time period as detail graph below
    [findSli(elem, slis).slo_status_panel { gridPos: { x: 14.5, y: elem * row, w: 9, h: 1 } }]
    +
    // Detail graph for this SLI, generated by metric specific library
    [findSli(elem, slis).graph { gridPos: { x: 14, y: elem * row, w: 10, h: 5 } }]
    for elem in std.range(0, std.length(std.objectFields(slis)) - 1)

  ];


// Adds the granfa title panel for a created dashbaord
// @param sliKey of a journey
// @param slis The list of SLIs for a journey
// @returns array defining the dashboard of one sli
local createDashboardInfo(sliKey, slis) =
  local sliRowTile = '%(sliKey)s: %(title)s' % {
    sliKey: sliKey,
    title: slis[std.objectFields(slis)[0]].title,
  };
  [
    [grafana.row.new(title=sliRowTile)] + std.flattenArrays(createPanelInfo(slis)),
  ];

// Creates the journey view dashboards for each journey in the service
// @param config The config for the service defined in the mixin file
// @param sliList The list of SLIs for a service
// @param links The links to other dashboards
// @returns JSON defining the journey view dashboards for a service
local createJourneyDashboards(config, sliList, links) =
  {
    [std.join('-', [macConfig.macDashboardPrefix.uid, config.product, journeyKey]) + '.json']:
      dashboard.new(
        title=stringFormattingFunctions.capitaliseFirstLetters(std.join(' / ', [macConfig.macDashboardPrefix.title, config.product, journeyKey])),
        uid=std.join('-', [macConfig.macDashboardPrefix.uid, config.product, journeyKey]),
        tags=[config.product, 'mac-version: %s' % config.macVersion, journeyKey, 'journey-view'],
        schemaVersion=18,
        editable=true,
        time_from='now-3h',
        refresh='5m',
      ).addLinks(
        dashboardLinks=links
      ).addTemplate(
        template.custom(
          name='error_budget_span',
          query='10m,1h,1d,7d,21d,30d,90d',
          current='7d',
          label='Error Budget Display',
        )
      ).addTemplates(
        config.templates
      ).addPanels(
        std.flattenArrays([
          std.flattenArrays(createDashboardInfo(sliKey, sliList[journeyKey][sliKey]))
          for sliKey in std.objectFields(sliList[journeyKey])
        ])
      )
    for journeyKey in std.objectFields(sliList)
  };

// File exports
{
  createJourneyDashboards(config, sliList, links): createJourneyDashboards(config, sliList, links),
}
