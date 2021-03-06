<!DOCTYPE html>
<html>

<head>

    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no"/>
    <link rel="shortcut icon" href="${assetPath(src: 'favicon.ico')}" type="image/x-icon">

    <title>Tilestore Administrator</title>

    <browser:choice>
        <browser:isMsie versionLower="10">
            <asset:stylesheet src="ol3/ol.css"/>
            <asset:stylesheet src="bootstrap.css"/>
            <asset:stylesheet src="font-awesome.css"/>
            <asset:stylesheet src="app/common/jquery.fileupload.css"/>
            <asset:stylesheet src="app/common/bootstrap-select.css"/>
            <asset:stylesheet src="app/common/ladda-themeless.min.css"/>
            <asset:stylesheet src="app/common/jquery.DataTables.css"/>
            <asset:stylesheet src="app/common/toastr.css"/>
            <asset:stylesheet src="app/common/fuelux.css"/>
            <asset:stylesheet src="app/admin/styles.css"/>
        </browser:isMsie>
        <browser:otherwise>
            <asset:stylesheet src="app/admin.css"/>
        </browser:otherwise>
    </browser:choice>


</head>

<body class="fuelux">

    <tilestore:securityClassificationBanner class="row text-center security-level-top"/>

    <div class="corner-ribbon top-left sticky red shadow">Alpha</div>

    <!-- Main navBar -->
    <div class="container">
        <nav id="navBarTop" class="navbar navbar-fixed-top navbar-default" role="navigation">
            <div class="container-fluid">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-navbar-collapse-1">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>

                    <g:link title="Go to Tile Server Home" action="index"><asset:image class="pull-left top-logo"
                                                                                       src="logo_nav.png"
                                                                                       alt="RBT Logo"/></g:link>
                    <a class="navbar-brand">&nbsp;&nbsp;Tilestore Administrator</a>
                </div>
                <div class="collapse navbar-collapse" id="bs-navbar-collapse-1">
                    <div class="col-sm-6 col-md-6">
                        <form class="navbar-form" role="search" id="zoomToForm">
                            <div class="form-group">
                                <a type="button" id="home" href="${createLink(uri:'/')}" class="btn btn-default"
                                   data-toggle="tooltip" data-placement="bottom"
                                   title="Go to Tilestore home page"><i
                                        class="fa fa-home"></i></a>
                                <a type="button" id="client" href="${createLink(controller:'app', action:'client')}"
                                   class="btn btn-default"
                                   data-toggle="tooltip" data-placement="bottom"
                                   title="Go to the Export page"><i
                                        class="fa fa-cube"></i></a>
                                <sec:ifAnyGranted roles="ROLE_LAYER_ADMIN,ROLE_ADMIN">
                                    <a type="button" id="admin" href="${createLink(controller:'app', action:'admin')}"
                                       class="btn btn-primary"
                                       data-toggle="tooltip" data-placement="bottom"
                                       title="Go to the Build page"><i
                                            class="fa fa-th"></i></a>
                                </sec:ifAnyGranted>
                                <sec:ifAllGranted roles="ROLE_ADMIN">
                                    <a type="button" id="disk" href="${createLink(controller:"diskCache")}"
                                       class="btn btn-default"
                                       data-toggle="tooltip" data-placement="bottom"
                                       title="Go to Disk Management page"><i
                                            class="fa fa-hdd-o"></i></a>
                                </sec:ifAllGranted>
                                <sec:ifAllGranted roles="ROLE_ADMIN">
                                    <a type="button" id="security" href="${createLink(controller: 'user')}" class="btn btn-default"
                                       data-toggle="tooltip" data-placement="bottom"
                                       title="Go to Security page"><i
                                            class="fa fa-unlock-alt"></i></a>
                                </sec:ifAllGranted>
                                <a type="button" id="jobs" href="${createLink(controller: 'job')}" class="btn btn-default"
                                   data-toggle="tooltip" data-placement="bottom"
                                   title="Go to Jobs page"><i
                                        class="fa fa-tachometer"></i></a>
                                <div class="input-group">
                                    <input class="form-control" id="coordInput" type="text"
                                           placeholder="Search by coordinates" data-toggle="tooltip" data-placement="bottom"
                                           title="Search for a coordinate via Decimal Degrees, Degrees Minutes Seconds, or Military Grid Reference System">
                                    <div class="input-group-btn">
                                        <button id="zoomButton" class="btn btn-primary" type="button"><i class="glyphicon glyphicon-search"></i></button>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <ul class="nav navbar-nav navbar-right">
                        <li>
                            <form class="navbar-form">
                                <div class="form-group">
                                    <div class="input-group" id="tileLayerInputGroup">
                                        <div class="input-group-addon"><i class="fa fa-th"></i></div>
                                        <select id="tileLayerSelect"
                                                class="form-control selectpicker show-tick" maxOptions="10"
                                                data-live-search="true">
                                        </select>
                                    </div>
                                </div>
                            </form>
                        </li>
                    <li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown"><i
                            class="fa fa-user"></i>&nbsp;&nbsp;<sec:loggedInUserInfo field="username"/><b class="caret"></b></a>
                        <ul class="dropdown-menu">
                            <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i class="fa fa-power-off">&nbsp;&nbsp;<g:link controller='logout'>Logout</g:link></i></li>
                        </ul>
                    </li>
                    </ul>
                </div><!-- /.navbar-collapse -->
            </div><!-- /.container-fluid -->
        </nav>
    </div><!-- /.container" -->

    <div class="navbar-offset"></div>

    <!-- toolBarRow -->
    <div class="container-fluid">
        <div id="toolBarRow" class="row">
            <div id="omarFeedToolbar" class="col-md-2 text-center">
                <nav class="navbar navbar-default">
                    <div class="container-fluid">
                        <div class="navbar-header">
                            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
                                <span class="icon-bar"></span>
                                <span class="icon-bar"></span>
                                <span class="icon-bar"></span>
                            </button>
                            <a class="navbar-brand">${message(code: 'admin.feed.label')}</a>
                        </div>
                        <div class="collapse navbar-collapse" id="omarFeedNavbar">
                            <ul class="nav navbar-nav navbar-right">
                                <li>
                                    <a id="wfsFilter" href="#" data-toggle="tooltip" data-placement="bottom"
                                       title="Filter OMAR image results"><i
                                        class="fa fa-filter"></i>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </nav>
            </div>
            <div id="mapOmarToolbar" class="col-md-5 text-center">
                <nav class="navbar navbar-default">
                    <div class="container-fluid">
                        <div class="navbar-header">
                            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
                                <span class="icon-bar"></span>
                                <span class="icon-bar"></span>
                                <span class="icon-bar"></span>
                            </button>
                            <a class="navbar-brand">Preview Map</a>
                        </div>
                        <div class="collapse navbar-collapse" id="previewMapNavbar">
                            <form class="navbar-form navbar-left" role="search">
                                <button type="button" id="ingestModalButton" class="btn btn-primary"
                                        data-toggle="tooltip" data-placement="bottom"
                                        title="Ingest the definied AOI or entire image"><i
                                        class="fa fa-sign-in fa-rotate-90"></i></button>
                                <button type="button" id="clearAoiButton" class="btn btn-primary"
                                        data-toggle="tooltip" data-placement="bottom"
                                        title="Clear the defined AOI"><i
                                        class="fa fa-trash-o"></i></button>
                            </form>
                            <ul class="nav navbar-nav navbar-right">
                                <li id="omarMapToolsDropdown" class="dropdown disabled">
                                    <a id="omarMapToolsDropdownItem" class="dropdown-toggle disabled"
                                       data-toggle="dropdown" href="#"><i
                                            class="fa fa-wrench"></i>&nbsp;&nbsp;Tools<span class="caret"></span></a>
                                    <ul class="dropdown-menu">
                                        <li role="presentation" class="dropdown-header">Manual cut</li>
                                        <li><a id="drawRectangle" href="#"><i class="fa fa-square-o fa-lg"></i>&nbsp;&nbsp;by
                                        Rectangle</a></li>
                                        <li><a id="drawPolygon" href="#"><i class="fa fa-hand-o-up fa-lg"></i>&nbsp;&nbsp;by
                                        Freehand Polygon</a></li>
                                        <li class="disabled"><a id="endCuts" href="#"><i
                                                class="fa fa-toggle-off fa-lg"></i>&nbsp;&nbsp;Manual Cutting Off</a></li>
                                        <li class="divider"></li>
                                        <li role="presentation" class="dropdown-header">Pre-generated cut</li>
                                        <li><a id="uploadCutFile" href="#"><i
                                                class="fa fa-upload fa-lg"></i>&nbsp;&nbsp;Upload Cut File</a></li>
                                        <li><a id="pasteGeometry" href="#"><i
                                                class="fa fa-paste fa-lg"></i>&nbsp;&nbsp;Paste Geometry</a></li>
                                    </ul>
                                </li>
                            </ul>
                        </div>
                    </div>
                </nav>
            </div>
            <div id="mapTileToolbar" class="col-md-5 text-center">
                <nav class="navbar navbar-default">
                    <div class="container-fluid">
                        <div class="navbar-header">
                            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
                                <span class="icon-bar"></span>
                                <span class="icon-bar"></span>
                                <span class="icon-bar"></span>
                            </button>
                            <a class="navbar-brand">Tile Map</a>
                        </div>
                        <div class="collapse navbar-collapse" id="tileMapNavbar">
                            <form class="navbar-form navbar-left" role="search">
                                <button type="button" id="viewLayersInfo" class="btn btn-info"
                                        data-toggle="tooltip" data-placement="bottom"
                                        title="View information about the available tile layers"><i
                                        class="fa fa-th-list"></i></button>
                            </form>
                            <ul class="nav navbar-nav navbar-right">
                                %{--<li><a href="#"><span class="glyphicon glyphicon-user"></span> Sign Up</a></li>--}%
                                %{--<li><a href="#"><span class="glyphicon glyphicon-log-in"></span> Login</a></li>--}%
                                <li class="dropdown">
                                    <a class="dropdown-toggle" data-toggle="dropdown" href="#"><i
                                            class="fa fa-wrench"></i>&nbsp;&nbsp;Tools<span class="caret"></span></a>
                                    <ul class="dropdown-menu">
                                        <li role="presentation" class="dropdown-header">Manage tile layers</li>
                                        <li><a id="navCreateLayer" href="#"><span
                                                class="fa fa-plus-square-o fa-lg"></span>&nbsp;&nbsp;Create Tile
                                        Layer</a></li>
                                        <li><a id="navRenameLayer" href="#"><span
                                                class="fa fa-pencil fa-lg"></span>&nbsp;&nbsp;Rename Tile
                                        Layer</a></li>
                                        <li><a id="navDeleteLayer" href="#"><span
                                                class="fa fa-trash fa-lg"></span>&nbsp;&nbsp;Delete Tile
                                        Layer</a></li>
                                        <li class="divider"></li>
                                        <li><a id="autoRefreshMapToggle" href="#"><i id="autoRefreshMapToggleIcon"
                                                                                     class="fa fa-toggle-off fa-lg"></i>&nbsp;&nbsp;Auto Refresh
                                        Map</a></li>
                                    </ul>
                                </li>
                            </ul>
                        </div>
                    </div>
                </nav>
            </div>
        </div><!-- /#toolBarRow -->
    </div><!-- /.container-fluid -->

    <!-- mapsRow -->
    <div class="container-fluid">
        <div id="mapsRow" class="row">
            <div id="omarFeed" class="col-md-2">
                <div>
                    <p>
                        <strong>Current Filter:&nbsp;</strong>
                        <span id="imageFilterDate" class="label label-primary"></span>
                        &nbsp;<span class="label label-success">and</span>&nbsp;
                        <span id="imageFilterRange" class="label label-primary"></span>
                    </p>
                    <p>
                        <small><em><span class="imageFilter"></span></em></small>
                    </p>
                    <p>
                        <strong>Number of Results:&nbsp;</strong>
                        <a href="#" data-toggle="tooltip" data-placement="bottom"
                           title="Number of images in current filter">
                            <span class="label label-primary label-as-badge">
                                <i class="fa fa-picture-o"></i>
                                <span id="imageCount"></span>
                            </span>
                        </a>
                    </p>
                    <p id="resultsSet"><small><em>Displaying <span id="startResult">1</span> through
                        <span id="endResult">25</span></em></small></p>
                    <div class="paginationButtons">
                        <div class="btn-group text-center col-md-12" >
                            <div class="center-block">
                                <button type="button" class="btn btn-primary prevWfsImages disabled">Prev
                                </button>
                                <button type="button" class="btn btn-primary nextWfsImages">Next</button>
                            </div>
                        </div>
                    </div>

                </div>
                <div id="omarImageList"></div>
                <div class="paginationButtons">
                    <div class="btn-group text-center col-md-12">
                        <div class="center-block">
                            <button type="button" class="btn btn-primary prevWfsImages disabled">Prev
                            </button>
                            <button type="button" class="btn btn-primary nextWfsImages">Next</button>
                        </div>
                    </div>
                </div>
            </div>
            <div id="mapOmar" class="col-md-5">
                <div id="mapOmarInfo" class="mapInfoBox mapInfoElement"></div>
                <div id="mapOmarZoomLevel" class="mapZoomLevel mapInfoElement"></div>
            </div>
            <div id="mapTile" class="col-md-5">
                %{--<div id="mapTileSpinner" class="mapSpinner mapInfoElement"><i class="fa fa-spinner fa-pulse fa-3x"></i></div>--}%
                <div id="mapTileZoomLevel" class="mapZoomLevel mapInfoElement"></div>
                <div id="mapTileInfo" class="mapInfoBox mapInfoElement"></div>
            </div>
        </div>
    </div>

    <!-- Create tile layer modal -->
    <div class="modal fade" id="createTileLayerModal" tabindex="-1" role="dialog" aria-labelledby="createTileLayerModalLabel" Saria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h3 class="modal-title"><i class="fa fa-th fa-lg"></i>&nbsp;&nbsp;Create a New Tile Layer</h3>
                </div>
                <div class="modal-body">
                    <div class="container">
                        <form id="createTileLayerForm" data-toggle="validator" role="form">
                            <div class="row col-sm-6 col-md-6">
                                <div class="form-group">
                                    <label for="createLayerName">Tile Layer Name&nbsp;</label>
                                    <input id="createLayerName" type="text" pattern="^[A-Za-z](?:_?[A-Za-z0-9]+)*$"
                                           maxlength="45"
                                           class="form-control" required>
                                    <span class="help-block"><small><em>Start with alphabetic, up to 45
                                    letters, numbers and underscores (case insensitive).  No spaces.</em></small></span>
                                    <span class="help-block with-errors"></span>
                                </div>
                                <div class="form-group">
                                    <label for="minTileLevel">Minimum Level</label>
                                    <select id="minTileLevel" class="form-control selectpicker show-tick"
                                            maxOptions="10" data-live-search="true">
                                    </select>
                                    <label for="maxTileLevel">Maximum Level</label>
                                    <select id="maxTileLevel" class="form-control selectpicker show-tick" maxOptions="10"
                                            data-live-search="true">
                                    </select><br><br>
                                    <label for="epsgCode">Projection</label>
                                    <select id="epsgCode" class="form-control selectpicker show-tick">
                                        <option value="EPSG:3857">EPSG: 3857</option>
                                        <option value="EPSG:4326">EPSG: 4326</option>
                                    </select>&nbsp;&nbsp;
                                    <label for="tileSize">Tile Size</label>
                                    <select class="form-control selectpicker show-tick" id="tileSize" disabled>
                                        <option value="256x256">256 x 256</option>
                                        <option value="512x512">512 x 512</option>
                                    </select><br><br>
                                    <div>
                                        <button id="submitCreateLayer" type="button" class="btn btn-primary ladda-button"
                                                data-style="expand-left"><span class="ladda-label">Create</span></button>
                                        <button id="resetCreateTile" type="button" class="btn btn-warning">Reset</button>
                                        <button id="cancelCreateTile" type="button" class="btn btn-default"
                                                data-dismiss="modal">Close</button>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div><!-- /.modal-body -->
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog modal-lg -->
    </div><!-- /.modal fade "createTileLayerModal" -->

    <!-- Rename tile layer modal -->
    <div class="modal fade" id="renameTileLayerModal" tabindex="-1" role="dialog" aria-labelledby="renameTileLayerModalLabel"
     Saria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h3 class="modal-title"><i class="fa fa-pencil fa-lg"></i>&nbsp;&nbsp;Rename Tile
                    Layers</h3>
                </div>
                <div class="modal-body">
                    <form id="renameTileLayerForm" data-toggle="validator" class="form">
                        <div class="container">
                            <div class="row col-sm-6 col-md-6">
                                <p>Select a layer from the list below, and then type the new layer name
                                in the input box.
                                </p>

                                <div class="form-group">
                                    <label for="renameTileLayer">Available Layers</label>
                                    <select id="renameTileLayer"
                                            class="form-control selectpicker show-tick tile-select">
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label for="renameLayerName">New Name&nbsp;</label>
                                    <input id="renameLayerName" type="text" pattern="^[A-Za-z](?:_?[A-Za-z0-9]+)*$"
                                           maxlength="45"
                                           class="form-control" required>
                                    <span class="help-block"><small><em>Start with alphabetic, up to 45
                                    letters, numbers and underscores (case insensitive).  No spaces.</em></small></span>
                                    <span class="help-block with-errors"></span>
                                </div>
                                <br>
                                <br>
                                <div>
                                    <button id="submitRenameLayer" type="button" class="btn btn-primary ladda-button"
                                            data-style="expand-left"><span class="ladda-label">Rename</span></button>
                                    <button id="cancelRenameTile" type="button" class="btn btn-default"
                                            data-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div><!-- /.modal-body -->
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog modal-lg -->
    </div><!-- /.modal fade "renameTileLayerModal" -->

    <!-- Delete tile layer modal -->
    <div class="modal fade" id="deleteTileLayerModal" tabindex="-1" role="dialog"
     aria-labelledby="deleteTileLayerModalLabel" Saria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h3 class="modal-title"><i class="fa fa-trash fa-lg"></i>&nbsp;&nbsp;Delete Tile Layers</h3>
                </div>
                <div class="modal-body">
                    <div class="container">
                        <form name="deleteTileLayerForm" role="form">
                            <div class="row col-sm-6 col-md-6">
                                <p>Select a layer from the list below, and then hit delete to remove the tile layer from
                                the server.
                                </p>
                                <div class="form-group">
                                    <label for="deleteTileLayer">Available Layers</label>
                                    <select id="deleteTileLayer" class="form-control selectpicker show-tick tile-select">
                                    </select>
                                    <br>
                                    <br>
                                    <div>
                                        <button id="submitDeleteLayer" type="button" class="btn btn-primary ladda-button"
                                                data-style="expand-left"><span class="ladda-label">Delete</span></button>
                                        <button id="cancelDeleteTile" type="button" class="btn btn-default"
                                                data-dismiss="modal">Close</button>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div><!-- /.modal-body -->
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal fade "deleteTileLayerModal" -->

    <!-- Filter wfs modal -->
    <div class="modal fade" id="filterWfsModal" tabindex="-1" role="dialog"
     aria-labelledby="filterwfsModalLabel" Saria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h3 class="modal-title"><i class="fa fa-filter fa-lg"></i>&nbsp;&nbsp;Filter OMAR Images</h3>
                </div>
                <div class="modal-body">
                    <!-- Date range select -->
                    <div class="form-group">
                        <div class="checkbox highlight" id="constrainToViewportCheckbox">
                            <label class="checkbox-custom checked highlight" data-initialize="checkbox" data-toggle="tooltip"
                                   data-placement="bottom"
                                   title="Restrict and view only the images that are in the current map extent">
                                <input class="sr-only" checked="checked" type="checkbox" value="" >
                                <span class="checkbox-label">Filter to images in current map
                                extent</span>
                            </label>
                        </div>

                        <label class="control-label" for="dateRangeSelect">Date Range</label>
                        <div class="btn-group selectlist filter-form-width"
                             data-initialize="selectlist"
                             id="dateRangeSelect" >
                            <button class="btn btn-default dropdown-toggle filter-form-width-inherit"
                                    data-toggle="dropdown"
                                    type="button">
                                <span class="selected-label">Date Range</span>
                                <span class="caret"></span>
                            </button>
                            <ul class="dropdown-menu filter-form-width" role="menu">
                                <li data-value="none"><a href="#">None</a></li>
                                <li data-value="today"><a href="#">Today</a></li>
                                <li data-value="yesterday"><a href="#">Yesterday</a></li>
                                <li data-value="last7Days"><a href="#">Last 7 days</a></li>
                                <li data-value="thisMonth"><a href="#">This month</a></li>
                                <li data-value="last3Months"><a href="#">Last 3 Months</a></li>
                                <li data-value="last6Months"><a href="#">Last 6 Months</a></li>
                                <li data-value="customDateRange"><a href="#">Custom Date Range</a></li>
                            </ul>
                            <input class="hidden hidden-field" name="dateRangeSelect" readonly="readonly"
                                   aria-hidden="true" type="text">
                        </div>
                        <br>
                        <br>
                        <!-- Custom date pickers -->
                        <div id="customFilterDates" class="filter-form-display-none">
                        <label class="control-label" for="customStartDateFilter">Start Date</label>
                            <div class="datepicker fuelux" id="customStartDateFilter">
                                <div class="input-group">
                                    <input class="form-control" id="customStartDateFilterInput" type="text" />
                                    <div class="input-group-btn">
                                        <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                            <span class="sr-only">Toggle Calendar</span>
                                        </button>
                                        <div class="dropdown-menu dropdown-menu-right datepicker-calendar-wrapper" role="menu">
                                            <div class="datepicker-calendar">
                                                <div class="datepicker-calendar-header">
                                                    <button type="button" class="prev"><span class="glyphicon glyphicon-chevron-left"></span><span class="sr-only">Previous Month</span></button>
                                                    <button type="button" class="next"><span class="glyphicon glyphicon-chevron-right"></span><span class="sr-only">Next Month</span></button>
                                                    <button type="button" class="title" data-month="11" data-year="2014">
                                                        <span class="month">
                                                            <span data-month="0">January</span>
                                                            <span data-month="1">February</span>
                                                            <span data-month="2">March</span>
                                                            <span data-month="3">April</span>
                                                            <span data-month="4">May</span>
                                                            <span data-month="5">June</span>
                                                            <span data-month="6">July</span>
                                                            <span data-month="7">August</span>
                                                            <span data-month="8">September</span>
                                                            <span data-month="9">October</span>
                                                            <span data-month="10">November</span>
                                                            <span data-month="11" class="current">December</span>
                                                        </span> <span class="year">2014</span>
                                                    </button>
                                                </div>
                                                <table class="datepicker-calendar-days">
                                                    <thead>
                                                    <tr>
                                                        <th>Su</th>
                                                        <th>Mo</th>
                                                        <th>Tu</th>
                                                        <th>We</th>
                                                        <th>Th</th>
                                                        <th>Fr</th>
                                                        <th>Sa</th>
                                                    </tr>
                                                    </thead>
                                                    <tbody></tbody>
                                                </table>
                                                <div class="datepicker-calendar-footer">
                                                    <button type="button" class="datepicker-today">Today</button>
                                                </div>
                                            </div>
                                            <div class="datepicker-wheels" aria-hidden="true">
                                                <div class="datepicker-wheels-month">
                                                    <h2 class="header">Month</h2>
                                                    <ul>
                                                        <li data-month="0"><button type="button">Jan</button></li>
                                                        <li data-month="1"><button type="button">Feb</button></li>
                                                        <li data-month="2"><button type="button">Mar</button></li>
                                                        <li data-month="3"><button type="button">Apr</button></li>
                                                        <li data-month="4"><button type="button">May</button></li>
                                                        <li data-month="5"><button type="button">Jun</button></li>
                                                        <li data-month="6"><button type="button">Jul</button></li>
                                                        <li data-month="7"><button type="button">Aug</button></li>
                                                        <li data-month="8"><button type="button">Sep</button></li>
                                                        <li data-month="9"><button type="button">Oct</button></li>
                                                        <li data-month="10"><button type="button">Nov</button></li>
                                                        <li data-month="11"><button type="button">Dec</button></li>
                                                    </ul>
                                                </div>
                                                <div class="datepicker-wheels-year">
                                                    <h2 class="header">Year</h2>
                                                    <ul></ul>
                                                </div>
                                                <div class="datepicker-wheels-footer clearfix">
                                                    <button type="button" class="btn datepicker-wheels-back"><span class="glyphicon glyphicon-arrow-left"></span><span class="sr-only">Return to Calendar</span></button>
                                                    <button type="button" class="btn datepicker-wheels-select">Select <span class="sr-only">Month and Year</span></button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <br>
                            <label class="control-label" for="customEndDateFilter">End Date</label>
                            <div class="datepicker fuelux" id="customEndDateFilter">
                                <div class="input-group">
                                    <input class="form-control" id="customEndDateFilterInput" type="text" />
                                    <div class="input-group-btn">
                                        <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                            <span class="sr-only">Toggle Calendar</span>
                                        </button>
                                        <div class="dropdown-menu dropdown-menu-right datepicker-calendar-wrapper" role="menu">
                                            <div class="datepicker-calendar">
                                                <div class="datepicker-calendar-header">
                                                    <button type="button" class="prev"><span class="glyphicon glyphicon-chevron-left"></span><span class="sr-only">Previous Month</span></button>
                                                    <button type="button" class="next"><span class="glyphicon glyphicon-chevron-right"></span><span class="sr-only">Next Month</span></button>
                                                    <button type="button" class="title" data-month="11" data-year="2014">
                                                        <span class="month">
                                                            <span data-month="0">January</span>
                                                            <span data-month="1">February</span>
                                                            <span data-month="2">March</span>
                                                            <span data-month="3">April</span>
                                                            <span data-month="4">May</span>
                                                            <span data-month="5">June</span>
                                                            <span data-month="6">July</span>
                                                            <span data-month="7">August</span>
                                                            <span data-month="8">September</span>
                                                            <span data-month="9">October</span>
                                                            <span data-month="10">November</span>
                                                            <span data-month="11" class="current">December</span>
                                                        </span> <span class="year">2014</span>
                                                    </button>
                                                </div>
                                                <table class="datepicker-calendar-days">
                                                    <thead>
                                                    <tr>
                                                        <th>Su</th>
                                                        <th>Mo</th>
                                                        <th>Tu</th>
                                                        <th>We</th>
                                                        <th>Th</th>
                                                        <th>Fr</th>
                                                        <th>Sa</th>
                                                    </tr>
                                                    </thead>
                                                    <tbody></tbody>
                                                </table>
                                                <div class="datepicker-calendar-footer">
                                                    <button type="button" class="datepicker-today">Today</button>
                                                </div>
                                            </div>
                                            <div class="datepicker-wheels" aria-hidden="true">
                                                <div class="datepicker-wheels-month">
                                                    <h2 class="header">Month</h2>
                                                    <ul>
                                                        <li data-month="0"><button type="button">Jan</button></li>
                                                        <li data-month="1"><button type="button">Feb</button></li>
                                                        <li data-month="2"><button type="button">Mar</button></li>
                                                        <li data-month="3"><button type="button">Apr</button></li>
                                                        <li data-month="4"><button type="button">May</button></li>
                                                        <li data-month="5"><button type="button">Jun</button></li>
                                                        <li data-month="6"><button type="button">Jul</button></li>
                                                        <li data-month="7"><button type="button">Aug</button></li>
                                                        <li data-month="8"><button type="button">Sep</button></li>
                                                        <li data-month="9"><button type="button">Oct</button></li>
                                                        <li data-month="10"><button type="button">Nov</button></li>
                                                        <li data-month="11"><button type="button">Dec</button></li>
                                                    </ul>
                                                </div>
                                                <div class="datepicker-wheels-year">
                                                    <h2 class="header">Year</h2>
                                                    <ul></ul>
                                                </div>
                                                <div class="datepicker-wheels-footer clearfix">
                                                    <button type="button" class="btn datepicker-wheels-back"><span class="glyphicon glyphicon-arrow-left"></span><span class="sr-only">Return to Calendar</span></button>
                                                    <button type="button" class="btn datepicker-wheels-select">Select <span class="sr-only">Month and Year</span></button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <br>

                        <!-- Date type radios -->
                        <label class="control-label" for="radios">Date Type</label>
                        <div class="controls">
                            <label class="radio-custom radio-inline" id="acquisitionDateRadioLabel"
                                   data-initialize="radio"
                                   for="acquisitionDateRadio">
                                <input class="sr-only " checked="checked" type="radio"
                                       id="acquisitionDateRadio" name="radios" value="Acquisition Date">
                                Acquisition
                            </label>

                            <label class="radio-custom radio-inline" id="ingestDateRadioLabel"
                                   data-initialize="radio" for="ingestDateRadio">
                                <input class="sr-only filter-form-width" checked="checked" type="radio" id="ingestDateRadio"
                                       name="radios" value="Ingest Date">
                                Ingest
                            </label>

                        </div>
                        <br>

                        <!-- Sort by field select -->
                        <div class="control-group">
                            <label class="control-label" for="sortByFieldSelect">Sort By Field</label>
                            <div class="controls">
                                <div class="btn-group selectlist filter-form-width"
                                     data-initialize="selectlist"
                                     id="sortByFieldSelect">
                                    <button class="btn btn-default dropdown-toggle filter-form-width-inherit"
                                            data-toggle="dropdown" type="button">
                                        <span class="selected-label">Sort By</span>
                                        <span class="caret"></span>
                                        <span class="sr-only">Toggle Dropdown</span>
                                    </button>
                                    <ul class="dropdown-menu filter-form-width" role="menu">
                                        <li data-value="id"><a href="#">Record ID</a></li>
                                        <li data-value="ingest_date"><a href="#">Ingest Date</a></li>
                                        <li data-value="acquisition_date"><a href="#">Acquisition Date</a></li>
                                        <li data-value="file_type"><a href="#">Image Type</a></li>
                                        <li data-value="sensor_id"><a href="#">Sensor</a></li>
                                        <li data-value="mission_id"><a href="#">Mision</a></li>
                                    </ul>
                                    <input class="hidden hidden-field" name="sortByFieldSelect" readonly="readonly"
                                           aria-hidden="true" type="text">
                                </div>
                            </div>
                        </div>
                        <br>

                        <!-- Sort type select -->
                        <div class="control-group">
                            <label class="control-label" for="sortByTypeSelect">Sort Type</label>
                            <div class="controls">
                                <div class="btn-group selectlist filter-form-width"
                                     data-initialize="selectlist"
                                     id="sortByTypeSelect">
                                    <button class="btn btn-default btn-block dropdown-toggle filter-form-width" data-toggle="dropdown" type="button">
                                        <span class="selected-label"></span>
                                        <span class="caret"></span>
                                    </button>
                                    <ul class="dropdown-menu filter-form-width" role="menu">
                                        <li data-value="D"><a href="#">Descending</a></li>
                                        <li data-value="A"><a href="#">Ascending</a></li>
                                    </ul>
                                    <input class="hidden hidden-field" name="sortTypeSelect"
                                           readonly="readonly"
                                           aria-hidden="true" type="text">
                                </div>
                            </div>
                        </div>
                        <br>

                    </div><!--/form group -->

                    <button id="submitFilter" class="btn btn-primary ladda-button"
                                        data-style="expand-left"><span class="ladda-label">Submit</span></button>
                    <button id="cancelFilter" type="button" class="btn btn-default"
                            data-dismiss="modal">Close</button>

                </div><!-- /.modal-body -->
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog modal-lg -->
    </div><!-- /.modal fade "deleteTileLayerModal" -->

    <!-- Upload cut by file form -->
    <div class="modal fade" id="uploadCutByFileModal" tabindex="-1" role="dialog" aria-labelledby="ModalLabel"
     Saria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h3 class="modal-title"><i class="fa fa-scissors fa-lg"></i>&nbsp;&nbsp;Upload cut from file
                </h3>
            </div>
            <div class="modal-body">
                <form id="uploadCutByFileForm" data-toggle="validator">
                    <div class="container">
                        <div class="row col-sm-6 col-md-6">

                            <div id="uploadCutByFormElements">
                                <p>Select a shapefile, geojson, or KML file, and upload to the server to perform the
                                cut for the
                                specified
                                geometries contained in the file.</p>
                                <p class="alert alert-info">You can also drag and drop the files into
                                the map to perform a cut.</p>

                                <input type="hidden" id="cutFormTargetEpsg" class="form-control"
                                       name="targetEpsg" value="EPSG:3857">

                                <input type="hidden" id="cutFormSourceEpsg" class="form-control"
                                       name="sourceEpsg" value="EPSG:3857">

                                <label for="sourceEpsgSelect">Set source projection</label>
                                <select id="sourceEpsgSelect" class="form-control selectpicker show-tick">
                                    <option value="EPSG:3857">EPSG: 3857</option>
                                    <option value="EPSG:4326">EPSG: 4326</option>
                                </select>
                                <br>
                                <br>
                                <!-- The fileinput-button span is used to style the file input field as button -->
                                <span class="btn btn-primary fileinput-button">
                                    <i class="fa fa-folder-open"></i>&nbsp;&nbsp;
                                    <span>Browse</span>
                                    <!-- The file input field used as target for the file upload widget -->
                                    <input id="fileupload" type="file" name="files[]" multiple>
                                </span>
                                <br>
                                <br>
                                <!-- The global progress bar -->
                                <div id="progress" class="progress">
                                    <div class="progress-bar progress-bar-success progress-bar-striped"></div>
                                </div>
                                <!-- The container for the uploaded files -->
                                <div id="files" class="files alert alert-success"></div>
                                <button id="closeUploadCutByFileModal" type="button" class="btn btn-primary pull-right"
                                        data-style="expand-left">Close</button>
                            </div>

                        </div>
                    </div><!-- /.container -->
                </form><!-- /#uploadCutByFileForm -->
            </div><!-- /.modal-body -->
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog modal-lg -->
</div><!-- /.modal fade "uploadCutByFileModal" -->

    <!-- Paste cut geometry form -->
    <div class="modal fade" id="pasteCutGeometryModal" tabindex="-1" role="dialog" aria-labelledby="ModalLabel"
     Saria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h3 class="modal-title"><i class="fa fa-paste fa-lg"></i>&nbsp;&nbsp;Paste geometry
                </h3>
            </div>
            <div class="modal-body">
                <form id="pasteCutGeometryForm" data-toggle="validator">
                    <div class="container">
                        <div class="row col-sm-6 col-md-6">

                            <div id="pasteCutGeometryElements">
                                <label for="geometryPasteTextArea">Paste geometry string (WKT, KML or GeoJSON)
                                &nbsp;</label>
                                <textarea id="geometryPasteTextArea" class="form-control" rows="6"></textarea>
                                <br>
                                <input type="hidden" id="pasteFormSourceEpsg" class="form-control"
                                       name="sourceEpsg" value="EPSG:3857">
                                <label for="pasteFormEpsgSourceSelect">Set source projection</label>
                                <select id="pasteFormEpsgSourceSelect" class="form-control selectpicker show-tick">
                                    <option value="EPSG:3857">EPSG: 3857</option>
                                    <option value="EPSG:4326">EPSG: 4326</option>
                                </select>
                                <br>
                                <br>
                                <button id="submitPasteGeometry" type="button" class="btn btn-primary"
                                        data-style="expand-left">Submit</button>
                                <button id="closePasteCutGeometryModal" type="button" class="btn btn-primary"
                                        data-style="expand-left">Close</button>
                            </div>

                        </div>
                    </div><!-- /.container -->
                </form><!-- /#pasteCutGeometryForm -->
            </div><!-- /.modal-body -->
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog modal-lg -->
</div><!-- /.modal fade "pasteCutGeometryModal" -->

    <!-- Ingest image modal -->
    <div class="modal fade" id="ingestImageModal" tabindex="-1" role="dialog"
     aria-labelledby="ingestImageModal" Saria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h3 class="modal-title"><i class="fa fa-file-image-o fa-lg"></i>&nbsp;&nbsp;Ingest Tile
                Image</h3>
            </div>
            <div class="modal-body">
                <div class="container">
                    <div class="row">
                        <div class="col-md-6 col-sm-6">

                            <p>Pick the desired minimum and maximum ingest levels for the selected image, and then
                            click the Submit button to start the process.</p>
                            <p><small><em>Note: The initial min and max levels below are determined by the resolution of the
                            selected image.</em></small></p>

                        </div>
                    </div><!-- /.row -->
                    <div class="row">

                        <div class="col-md-3 col-sm-3">

                            <label for="minIngestLevel">Minimum Level</label>
                            <select id="minIngestLevel" class="form-control"></select>

                        </div>
                        <div class="col-md-3 col-sm-3">

                            <label for="maxIngestLevel">Maximum Level</label>
                            <select id="maxIngestLevel" class="form-control"></select>

                        </div>
                    </div><!-- /.row -->
                    <br>
                    <div class="row">
                        <div class="col-md-6 col-sm-6">
                            <button id="submitIngestImage" class="btn btn-primary ladda-button"
                                    data-style="expand-left"><span class="ladda-label">Submit</span></button>
                            <button id="cancelIngestImage" type="button" class="btn btn-default"
                                    data-dismiss="modal">Close</button>
                        </div>
                    </div><!-- /.row -->

                </div><!-- /.container -->
            </div><!-- /.modal-body -->
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog modal-lg -->
</div><!-- /.modal fade "ingestImageModal" -->

    <!-- List layers modal -->
    <div class="modal fade" id="listLayersModal" tabindex="-1" role="dialog"
     aria-labelledby="listLayersModal" Saria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h3 class="modal-title"><i class="fa fa-th-list fa-lg"></i>&nbsp;&nbsp;Tile Layers
                List</h3>
            </div>
            <div class="modal-body">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-md-12 col-sm-12">
                            <div id="layerTableInfo" class="alert alert-info text-center" role="alert"><strong>Click on
                            any
                            table row to
                            set
                            that layer as
                            the
                            active
                            layer</strong></div>
                            <table id="layers_table" class="display">
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th>EPSG</th>
                                        <th>Min Level</th>
                                        <th>Max Level</th>
                                        <th>Tile Height</th>
                                        <th>Tile Width</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                    </tr>
                                </tbody>
                                <tfoot>
                                <tr>
                                    <th>Name</th>
                                    <th>EPSG</th>
                                    <th>Min Level</th>
                                    <th>Max Level</th>
                                    <th>Tile Height</th>
                                    <th>Tile Width</th>
                                </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div><!-- /.row -->
                    <br>
                </div><!-- /.container -->
            </div><!-- /.modal-body -->
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog modal-lg -->
</div><!-- /.modal fade "listLayersModal" -->

    <!-- OMAR WFS Feed Handlebars template -->
    <script id="image-template"  type="text/x-handlebars-template">
    {{#features}}
    <div id="card-{{properties.id}}" class="row image-card">
        <div>
            <div class="col-md-2 image-card-thumb">
                <img data-toggle="tooltip" data-placement="bottom"
                     data-name="{{properties.id}}"
                     onclick="AppOmarWfsAdmin.previewLayer({{json this}})"
                     title="Click on thumbnail to preview image" class="omar-thumb"
                     src="${grailsApplication.config.omar.url}/thumbnail/show/{{properties.id}}" alt="Image thumbnail"
                     size="100">
            </div>
            <div class="col-md-8 image-card-info">
                <strong>ID: </strong>{{properties.id}}&nbsp;&nbsp;<strong>Type: </strong>
                {{properties.file_type}}<br>
                <strong>Acq. Date: </strong>{{formatDate properties.acquisition_date}}<br>
                <strong>Ingest Date: </strong>{{formatDate properties.ingest_date}}<br>
                <strong>Sensor: </strong>{{formatString properties.sensor_id}}<br>
                <strong>Mission: </strong><span>{{formatString properties.mission_id}}</span>
                <hr>
                &nbsp;&nbsp;
                %{--<a href="#"><i id="viewMetadata" class="fa fa-ellipsis-h fa-lg" onclick="alert('viewing metadata');"--}%
                               %{--data-toggle="tooltip" data-placement="bottom"--}%
                   %{--title="View image metadata"></i></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--}%
                <a href="${grailsApplication.config.omar.url}/mapView/imageSpace?layers={{properties.id}}"
                   target="_blank"><i id="viewInOmar" class="fa fa-globe fa-lg" data-toggle="tooltip" data-placement="bottom"
                                      title="View image in OMAR"></i></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                %{--<a target="_blank" id="ingestImageFromCard" style="display: none;"><i id="ingestToCurrentTileLayer"--}%
                                      %{--data-name="{{properties.id}}"--}%
                                      %{--onclick="AppIngestTileAdmin.ingestModalShow({{json this}})"--}%
                                      %{--class="fa fa-sign-in fa-lg ingestToCurrentTileLayer" data-toggle="tooltip"--}%
                                      %{--data-placement="bottom"--}%
                                      %{--title="Ingest image into currently selected tile layer"></i></a>--}%
                <br>
                <br>
            </div>
        </div>
    </div>
    {{/features}}
</script>

    <tilestore:securityClassificationBanner class="navbar navbar-default navbar-fixed-bottom text-center security-level-bottom"/>

    <asset:javascript src="app/admin.js"/>
    <g:javascript>
        $( document ).ready( function ()
        {
            "use strict";
            var initParams = ${raw( initParams.toString() )};
            //console.log('The params are:');
            //console.log(initParams);

            AppManageLayersAdmin.initialize(initParams);
            AppAdmin.initialize(initParams);
            AppOmarWfsAdmin.initialize(initParams);
            AppIngestTileAdmin.initialize(initParams);
            AppDrawFeaturesAdmin.initialize(initParams);
            CutByFileAdmin.initialize(initParams);

            //Use polyfill to utilize HTML5 form validation in IE9
            H5F.setup(document.getElementById("createTileLayerForm"));
            H5F.setup(document.getElementById("renameTileLayerForm"));

        } );
</g:javascript>



</body>

</html>
