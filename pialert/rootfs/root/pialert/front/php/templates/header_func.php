<?php
// Delete Single WebGUI Reports
function useRegex($input) {
	$regex = '/[0-9]+-[0-9]+_.*\\.txt/i';
	return preg_match($regex, $input);
}
function delete_single_webgui_report() {
	global $db;

	if (isset($_REQUEST['remove_report'])) {
		$prep_remove_report = str_replace(array('\'', '"', ',', ';', '<', '>', '.', '/', '&'), "", $_REQUEST['remove_report']) . '.txt';
		if (useRegex($prep_remove_report) == TRUE) {
			if (file_exists('./reports/' . $prep_remove_report)) {
				unlink('./reports/' . $prep_remove_report);
				// Logging
				pialert_logging('a_050', $_SERVER['REMOTE_ADDR'], 'LogStr_0503', '', $prep_remove_report);
			}
		}
	}
}
// Pause Arp Scan Section
function arpscanstatus() {
	global $pia_lang;
	if (!file_exists('../db/setting_stoppialert')) {
		$execstring = 'ps -aux | grep "/pialert/back/pialert.py 1" | grep -v grep | sed \'/>~\/pialert\/log\/pialert.1.log/d\'';
		$pia_arpscans = "";
		exec($execstring, $pia_arpscans);
		$arp_proc_count = sizeof($pia_arpscans);
		unset($_SESSION['arpscan_timerstart']);
		$_SESSION['arpscan_result'] = '<span id="arpproccounter">' . $arp_proc_count . '</span> ' . $pia_lang['Maintenance_arp_status_on'] . ' <div id="nextscancountdown" style="display: inline-block;"></div>';
		$_SESSION['arpscan_sidebarstate'] = 'Active';
		$_SESSION['arpscan_sidebarstate_light'] = 'green-light fa-gradient-green';
	} else {
		$_SESSION['arpscan_timerstart'] = date("H:i:s", filectime('../db/setting_stoppialert'));
		$_SESSION['arpscan_result'] = '<span style="color:red;">arp-Scan ' . $pia_lang['Maintenance_arp_status_off'] . '</span> <div id="nextscancountdown" style="display: none;"></div>';
		$_SESSION['arpscan_sidebarstate'] = 'Disabled&nbsp;&nbsp;&nbsp;(' . $_SESSION['arpscan_timerstart'] . ')';
		$_SESSION['arpscan_sidebarstate_light'] = 'red fa-gradient-red';
	}
}
// Systeminfo in Sidebar
function getTemperature() {
	if (file_exists('/sys/class/thermal/thermal_zone0/temp')) {
		$output = rtrim(file_get_contents('/sys/class/thermal/thermal_zone0/temp'));
	} elseif (file_exists('/sys/class/hwmon/hwmon0/temp1_input')) {
		$output = rtrim(file_get_contents('/sys/class/hwmon/hwmon0/temp1_input'));
	} else {
		$output = '';
	}
	// Test if we succeeded in getting the temperature
	if (is_numeric($output)) {
		// $output could be either 4-5 digits or 2-3, and we only divide by 1000 if it's 4-5 (ex. 39007 vs 39)
		$celsius = intval($output);
		// If celsius is greater than 1 degree and is in the 4-5 digit format
		if ($celsius > 1000) {
			// Use multiplication to get around the division-by-zero error
			$celsius *= 1e-3;
		}
		$limit = 60;
	} else {
		// Nothing can be colder than -273.15 degree Celsius (= 0 Kelvin).This is the minimum temperature possible
		$celsius = -273.16;
		// Set templimit to null if no tempsensor was found
		$limit = null;
	}
	return array($celsius, $limit);
}

function getMemUsage() {
	$data = explode("\n", file_get_contents('/proc/meminfo'));
	$meminfo = array();
	if (count($data) > 0) {
		foreach ($data as $line) {
			$expl = explode(':', $line);
			if (count($expl) == 2) {
				// remove " kB" from the end of the string and make it an integer
				$meminfo[$expl[0]] = intval(trim(substr($expl[1], 0, -3)));
			}
		}
		$memused = $meminfo['MemTotal'] - $meminfo['MemFree'] - $meminfo['Buffers'] - $meminfo['Cached'];
		$memusage = $memused / $meminfo['MemTotal'];
	} else {
		$memusage = -1;
	}
	return $memusage;
}

function format_MemUsage($memory_usage) {
	echo '<span><i class="fa fa-w fa-circle ';
	if ($memory_usage > 0.75 || $memory_usage < 0.0) {
		echo 'text-red fa-gradient-red';
	} else {
		echo 'text-green-light fa-gradient-green';
	}
	if ($memory_usage > 0.0) {
		echo '"></i> Memory usage:&nbsp;&nbsp;' . sprintf('%.1f', 100.0 * $memory_usage) . '&thinsp;%</span>';
	} else {
		echo '"></i> Memory usage:&nbsp;&nbsp; N/A</span>';
	}
}

function format_sysloadavg($loaddata) {
	$nproc = shell_exec('nproc');
	if (!is_numeric($nproc)) {
		$cpuinfo = file_get_contents('/proc/cpuinfo');
		preg_match_all('/^processor/m', $cpuinfo, $matches);
		$nproc = count($matches[0]);
	}
	echo '<span title="Detected ' . $nproc . ' cores"><i class="fa fa-w fa-circle ';
	if ($loaddata[0] > $nproc) {
		echo 'text-red fa-gradient-red';
	} else {
		echo 'text-green-light fa-gradient-green';
	}
	echo '"></i> Load:&nbsp;&nbsp;' . round($loaddata[0], 2) . '&nbsp;&nbsp;' . round($loaddata[1], 2) . '&nbsp;&nbsp;' . round($loaddata[2], 2) . '</span>';
}

function format_temperature($celsius, $temperaturelimit) {
	if ($celsius >= -273.15) {
		// Only show temp info if any data is available -->
		$tempcolor = 'text-vivid-blue';
		if (isset($temperaturelimit) && $celsius > $temperaturelimit) {
			$tempcolor = 'text-red fa-gradient-red';
		}
		echo '<span id="temperature"><i class="fa fa-w fa-fire ' . $tempcolor . '" style="width: 1em !important"></i> ';
		echo 'Temp:&nbsp;<span id="rawtemp" hidden>' . $celsius . '</span>';
		echo '<span id="tempdisplay"></span></span>';
	}
}
// Web Services Menu Items
function toggle_webservices_menu($section) {
	global $pia_lang;
	if (($_SESSION['Scan_WebServices'] == True) && ($section == "Main")) {
		echo '<li class="';
		if (in_array(basename($_SERVER['SCRIPT_NAME']), array('services.php', 'serviceDetails.php'))) {echo 'active';}
		echo '">
                <a href="services.php">
                	<i class="fa fa-globe"></i>
                	<span>' . $pia_lang['Navigation_Services'] . '</span>
		          	<span class="pull-right-container">
		              <small class="label pull-right bg-yellow" id="header_services_count_warning"></small>
		              <small class="label pull-right bg-red" id="header_services_count_down"></small>
		              <small class="label pull-right bg-green" id="header_services_count_on"></small>
		            </span>
                </a>
              </li>';
	}
}
// ICPMScan Menu Items
function toggle_icmpscan_menu($section) {
	global $pia_lang;
	if (($_SESSION['ICMPScan'] == True) && ($section == "Main")) {
		echo '<li class="';
		if (in_array(basename($_SERVER['SCRIPT_NAME']), array('icmpmonitor.php', 'icmpmonitorDetails.php'))) {echo 'active';}
		echo '">
                <a href="icmpmonitor.php">
                    <i class="fa fa-magnifying-glass"></i>
                    <span>' . $pia_lang['Navigation_ICMPScan'] . '</span>
					<span class="pull-right-container">
						<small class="label pull-right bg-red" id="header_icmp_count_down"></small>
						<small class="label pull-right bg-green" id="header_icmp_count_on"></small>
					</span>
                </a>
              </li>';
	}
}
// Parse Config file
function get_config_parmeter($config_param) {
	$configContent = file_get_contents('../config/pialert.conf');
	$configContent = preg_replace('/^\s*#.*$/m', '', $configContent);
	$configArray = parse_ini_string($configContent);
	if (isset($configArray[$config_param])) {return $configArray[$config_param];} else {return False;}
}
// Set Session Vars
if (get_config_parmeter('ICMPSCAN_ACTIVE') == 1) {$_SESSION['ICMPScan'] = True;} else { $_SESSION['ICMPScan'] = False;}
if (get_config_parmeter('SCAN_WEBSERVICES') == 1) {$_SESSION['Scan_WebServices'] = True;} else { $_SESSION['Scan_WebServices'] = False;}
if (get_config_parmeter('ARPSCAN_ACTIVE') == 1) {$_SESSION['Scan_MainScan'] = True;} else { $_SESSION['Scan_MainScan'] = False;}
if (get_config_parmeter('AUTO_UPDATE_CHECK') == 1) {$_SESSION['Auto_Update_Check'] = True;} else { $_SESSION['Auto_Update_Check'] = False;}

// State for Toggle Buttons
function convert_state($state, $revert) {
	global $pia_lang;
	if ($revert == 1) {
		if ($state == 1) {return $pia_lang['Gen_off'];} else {return $pia_lang['Gen_on'];}
	} elseif ($revert == 0) {
		if ($state != 1) {return $pia_lang['Gen_off'];} else {return $pia_lang['Gen_on'];}
	}
}

// Back button for details pages
function insert_back_button() {
	$pagename = basename($_SERVER['PHP_SELF']);
	if ($pagename == 'serviceDetails.php') {
		$backto = 'services.php';
	}
	if ($pagename == 'deviceDetails.php') {
		$backto = 'devices.php';
	}
	if ($pagename == 'icmpmonitorDetails.php') {
		$backto = 'icmpmonitor.php';
	}
	if (isset($backto)) {
		echo '<a id="navbar-back-button" href="./' . $backto . '" role="button" style="">
        <i class="fa fa-chevron-left"></i>
      </a>';
	}
}
// Adjust Logo Color
function set_userimage($skinname) {
	if ($skinname == 'skin-black-light' || $skinname == 'skin-black'|| $skinname == 'leiweibau_light') {
		$_SESSION['UserLogo'] = 'pialertLogoBlack';
	} else {$_SESSION['UserLogo'] = 'pialertLogoWhite';}
}

// Get DeviceList Filters
function get_devices_filter_list() {
	$database = '../db/pialert.db';
	$db = new SQLite3($database);
	$sql_select = 'SELECT * FROM Devices_table_filter ORDER BY filtername ASC';
	$result = $db->query($sql_select);
	if ($result) {
		if ($result->numColumns() > 0) {
	        while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
	        	if ($row['filterstring'] == $_REQUEST['predefined_filter']) {$filterlist_icon = "fa-solid fa-circle";} else {$filterlist_icon = "fa-regular fa-circle";}
	            echo '<li><a href="devices.php?predefined_filter='.urlencode($row['filterstring']).'" style="font-size: 14px; height: 30px; line-height:30px;padding:0;padding-left:25px;"><i class="'.$filterlist_icon.'" style="margin-right:5px;"></i>'. $row['filtername'] .'</a></li>';
	        }
		}
	} else {echo "";}
	$db->close();
}

// Arp Histroy Graph
if (file_exists('../db/setting_noonlinehistorygraph')) {$ENABLED_HISTOY_GRAPH = False;} else { $ENABLED_HISTOY_GRAPH = True;}

// Prüfe ob es ein Theme gibt, wenn ja, Darkmode soll über css ausgeblendet werden
$themefile = '../db/setting_theme*';
$theme_result = glob($themefile);
// Check if any matching files were found
if (!empty($theme_result)) {
	foreach ($theme_result as $file) {
		$themename_file = str_replace('setting_theme_', '', basename($file));
		$ENABLED_THEMEMODE = True;
		$ENABLED_DARKMODE = False;
		$skin_selected_head = '<link rel="stylesheet" href="lib/AdminLTE/dist/css/skins/skin-blue.min.css">';
		$skin_selected_body = '<body class="hold-transition skin-blue sidebar-mini" >';
		$theme_selected_head = '<link rel="stylesheet" href="css/themes/' . $themename_file . '/' . $themename_file . '.css">';
		set_userimage($themename_file);
	}
} else {
	// Darkmode
	if (file_exists('../db/setting_darkmode')) {$ENABLED_DARKMODE = True;} else { $ENABLED_DARKMODE = False;}
	// Use saved AdminLTE Skin
	foreach (glob("../db/setting_skin*") as $filename) {
		$skinname_file = str_replace('setting_', '', basename($filename));
		$skin_selected_head = '<link rel="stylesheet" href="lib/AdminLTE/dist/css/skins/' . $skinname_file . '.min.css">';
		$skin_selected_body = '<body class="hold-transition ' . $skinname_file . ' sidebar-mini" >';
		set_userimage($skinname_file);
	}
	// Use fallback AdminLTE Skin
	if (strlen($skin_selected_head) == 0) {
		$skin_selected_head = '<link rel="stylesheet" href="lib/AdminLTE/dist/css/skins/skin-blue.min.css">';
		$skin_selected_body = '<body class="hold-transition skin-blue sidebar-mini" >';
		set_userimage("skin-blue");
	}
}

// Language
foreach (glob("../db/setting_language*") as $filename) {
	$pia_lang_selected = str_replace('setting_language_', '', basename($filename));
}
if (strlen($pia_lang_selected) == 0) {$pia_lang_selected = 'en_us';}
// FavIcon
if (file_exists('../db/setting_favicon')) {
	$FRONTEND_FAVICON = file('../db/setting_favicon', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES)[0];
} else {
	$FRONTEND_FAVICON = 'img/favicons/flat_blue_white.png';
}
?>