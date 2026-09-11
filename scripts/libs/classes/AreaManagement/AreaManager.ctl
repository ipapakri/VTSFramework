// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/AreaManagement/Area"
#uses "classes/AreaManagement/UserClass"
#uses "classes/navigation/NavigationCatalog"
#uses "classes/navigation/NavigationTarget"

//--------------------------------------------------------------------------------
// Variables and Constants
//--------------------------------------------------------------------------------
/**
*/
class AreaManager
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  public static const int READ_ACCESS_BIT = 0;
  public static const int WRITE_ACCESS_BIT = 1;

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  private AreaManager()
  {
    initialize();
    connect();
  }

  public static bool isAdminUser(string userName)
  {
    if (userName == "root" || userName == "admin" || userName == "operator")
    {
      return true;
    }

    return false;
  }

  synchronized public static shared_ptr<AreaManager> instance()
  {
    if(areaManager == nullptr) {
      areaManager = new AreaManager();
    }

    return areaManager;
  }

  private void connect()
  {
    string query = "SELECT '_original.._value' FROM '*' WHERE _DPT = \"UserPermissions\"";
    dpQueryConnectSingle("connectCb", false, "", query);
  }

  private void connectCb(string userData, dyn_dyn_anytype ddaTab)
  {
    if(isAnswer())
    {
      initialize();
    }
  }

  private void initialize()
  {
    mappingClear(areas);
    mappingClear(users);
    for(int i=1; i<=dynlen(areaTypes); i++)
    {
      dyn_string areasLocal = dpNames("*", areaTypes[i]);
      for(int j=1; j<=dynlen(areasLocal); j++)
      {
        shared_ptr<Area> area = new Area(areasLocal[j]);
        areas[areasLocal[j]] = area;
      }
    }

    dyn_string usersLocal = dpNames("*", userTypes);
    for(int i=1; i<=dynlen(usersLocal); i++)
    {
      shared_ptr<UserClass> user = new UserClass(usersLocal[i], this.areas);
      users[dpSubStr(usersLocal[i], DPSUB_DP)] = user;
    }
  }

  public static string getCurrentUser()
  {
    string currentUser;
    dpGet(myUiDpName()+".UserName", currentUser);
    return currentUser;
  }

  /*
  public shared_ptr<Area> getAreaByDp(string dp)
  public shared_ptr<User> getUserByName(string name)
  */

  public bool userHasPermission(string userName, string areaDp, int permission)
  {
    if(userName == "")
    {
      return false;
    }
    else if (isAdminUser(userName))
    {
      return true;
    }
    else if (!mappingHasKey(this.users, userName))
    {
      // No UserPermissions datapoint for this login: grants nothing rather
      // than dereferencing a null user.
      return false;
    }
    return this.users[userName].hasPermission(areaDp, permission);
  }

  public mapping getAreasForUser(string userName)
  {
    return users[userName].getAreas();
  }

  /**
    The hierarchy the per-user sum alerts are built from. Without it
    updateUserAccessRights() only writes the permissions.
  */
  public void setNavigationCatalog(shared_ptr<NavigationCatalog> navigationCatalog)
  {
    this.navigationCatalog = navigationCatalog;
  }

  public void updateUserAccessRights(string userName, const mapping& userAccessLevels)
  {
    dyn_string userAreas = mappingKeys(userAccessLevels);
    dyn_int userAreasLevels;

    for(int i=1; i<=dynlen(userAreas); i++)
    {
      dynAppend(userAreasLevels, userAccessLevels[userAreas[i]]);
    }
    dpSet(userName + "." + USER_AREAS_ELEMENT, userAreas,
          userName + "." + USER_PERMISSIONS_ELEMENT, userAreasLevels);

    generateUserSumAlerts(userName);
  }

  /**
    Rebuilds the sum alert tree for one user: one sum alert datapoint per
    catalog branch that still has a leaf the user may read below it.
  */
  private void generateUserSumAlerts(string userName)
  {
    if (navigationCatalog == nullptr)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__,
              "No navigation catalog set, cannot generate sum alerts for", userName);
      return;
    }

    processNode(navigationCatalog.getRootId(), userName);
  }

  /**
    The datapoint the parent has to sum up: the leaf itself when the user may
    read it, the branch's own sum alert datapoint when anything below it
    survived, and "" when nothing did.
  */
  private string processNode(string id, string userName)
  {
    shared_ptr<NavigationTarget> target = navigationCatalog.resolve(id);

    if (target == nullptr)
    {
      return "";
    }

    dyn_string childIds = navigationCatalog.getChildIds(id);

    if (dynlen(childIds) == 0)
    {
      string dp = target.getDatapoint();

      if (dp == "" || !userHasPermission(userName, dp, READ_ACCESS_BIT))
      {
        return "";
      }

      return dp;
    }

    dyn_string childrenAlarms;

    for (int i = 1; i <= dynlen(childIds); i++)
    {
      string childAlarm = processNode(childIds[i], userName);

      if (childAlarm != "")
      {
        dynAppend(childrenAlarms, childAlarm);
      }
    }

    if (dynlen(childrenAlarms) == 0)
    {
      return "";
    }

    string dpName = sumAlertDpName(id, userName);

    createSumAlertDp(dpName);
    configureSumAlert(dpName, target, childrenAlarms);

    return dpName;
  }

  /**
    A catalog id carries the view name and the path separators, none of which a
    datapoint name may contain, so every character outside [A-Za-z0-9_]
    collapses to an underscore.
  */
  private string sumAlertDpName(string id, string userName)
  {
    return SUM_ALERT_DP_PREFIX + toDpNameToken(id) + "_" + toDpNameToken(userName);
  }

  private string toDpNameToken(string text)
  {
    string token;

    for (int i = 0; i < strlen(text); i++)
    {
      string character = substr(text, i, 1);

      if ((character >= "a" && character <= "z") ||
          (character >= "A" && character <= "Z") ||
          (character >= "0" && character <= "9"))
      {
        token += character;
      }
      else
      {
        token += "_";
      }
    }

    return token;
  }

  private void createSumAlertDp(string dpName)
  {
    int error;

    if (!dpExists(dpName))
    {
      dpCopy(SUM_ALERT_MASTER_DP, dpName, error);
    }
    else
    {
      dyn_string masterDpes = dpNames(SUM_ALERT_MASTER_DP + ".*");

      for (int i = 1; i <= dynlen(masterDpes); i++)
      {
        string dpe = masterDpes[i];
        strreplace(dpe, dpSubStr(masterDpes[i], DPSUB_DP), dpName);

        int alertType;
        dpGet(dpe + ":_alert_hdl.._type", alertType);

        // Only the elements the master gained since this copy was made.
        if (alertType != DPCONFIG_SUM_ALERT)
        {
          dpCopyConfig(dpSubStr(masterDpes[i], DPSUB_DP_EL), dpName, makeDynString("_alert_hdl"), error);
        }
      }
    }

    if (error)
    {
      throwError(makeError("", PRIO_INFO, ERR_SYSTEM, 0,
                           "generateUserSumAlerts:::dpCopy:::error " + error +
                           " ( " + SUM_ALERT_MASTER_DP + " -> " + dpName + " )"));
    }
  }

  private void configureSumAlert(string dpName,
                                 shared_ptr<NavigationTarget> target,
                                 const dyn_string& childrenAlarms)
  {
    dyn_int        prioMin, prioMax;
    dyn_string     prioRange;
    dyn_string     defaultDps = makeDynString(getSystemName() + "_TmpBitAlert.");
    dyn_string     parameters = alertPanelParameters(target);
    string         panel = target.getPanelFile();
    dyn_langString dlOn, dlOff;
    unsigned       uAckHasPrio, uOrder;
    langString     help;
    int            aType;

    dpGet("_SumAlertGeneral.prioRange.name:_online.._value",    prioRange,
          "_SumAlertGeneral.prioRange.min:_online.._value",     prioMin,
          "_SumAlertGeneral.prioRange.max:_online.._value",     prioMax,
          "_SumAlertGeneral.prioRange.textOn:_online.._value",  dlOn,
          "_SumAlertGeneral.prioRange.textOff:_online.._value", dlOff,
          "_SumAlertGeneral.ack_has_prio:_online.._value",      uAckHasPrio,
          "_SumAlertGeneral.order:_online.._value",             uOrder);

    for (int j = 1; j <= dynlen(prioRange); j++)
    {
      dyn_string prioRangeChildrenAlarms = alertSources(childrenAlarms, prioRange[j]);
      string dpe = dpName + "." + prioRange[j];
      dpGet(dpe + ":_alert_hdl.._type", aType);

      if (aType != DPCONFIG_SUM_ALERT)
      {
        dpSetTimed(0L, dpe+":_alert_hdl.._type", DPCONFIG_SUM_ALERT); // IM 106203
        dpSetTimed(0L, dpe+":_alert_hdl.._text1",        dlOn[j],
                       dpe+":_alert_hdl.._text0",        dlOff[j],
                       dpe+":_alert_hdl.._class",        "",
                       dpe+":_alert_hdl.._ack_has_prio", uAckHasPrio,
                       dpe+":_alert_hdl.._order",        2,
                       dpe+":_alert_hdl.._dp_list",      makeDynString("_TmpBitAlert."),
                       dpe+":_alert_hdl.._dp_pattern",   "",
                       dpe+":_alert_hdl.._prio_pattern", prioMin[j]+"-"+prioMax[j],
                       dpe+":_alert_hdl.._abbr_pattern", "",
                       dpe+":_alert_hdl.._ack_deletes",  true,
                       dpe+":_alert_hdl.._non_ack",      true,
                       dpe+":_alert_hdl.._came_ack",     true,
                       dpe+":_alert_hdl.._pair_ack",     true,
                       dpe+":_alert_hdl.._both_ack",     true,
                       dpe+":_alert_hdl.._panel",        "",
                       dpe+":_alert_hdl.._panel_param",  makeDynString(),
                       dpe+":_alert_hdl.._help",         help);
      }

      bool ok;
      dpDeactivateAlert(dpe, ok, true);

      dpSetTimed(0L, dpe+":_alert_hdl.._dp_list",      (dynlen(prioRangeChildrenAlarms) > 0) ? prioRangeChildrenAlarms : defaultDps, // IM 106203
                     dpe+":_alert_hdl.._panel",        panel,
                     dpe+":_alert_hdl.._panel_param",  parameters,
                     dpe+":_alert_hdl.._prio_pattern", prioMin[j]+"-"+prioMax[j],
                     dpe+":_alert_hdl.._ack_has_prio", uAckHasPrio,
                     dpe+":_alert_hdl.._order",        uOrder);

      dpActivateAlert(dpe, ok, true);
    }
  }

  /**
    A child contributes its own datapoint alert when it has one configured,
    otherwise the element carrying the matching priority range.
  */
  private dyn_string alertSources(const dyn_string& childrenAlarms, string prioRangeName)
  {
    dyn_string sources;

    for (int i = 1; i <= dynlen(childrenAlarms); i++)
    {
      int alertType = DPCONFIG_NONE;

      if (dpExists(childrenAlarms[i] + ".:_alert_hdl.._type"))
      {
        dpGet(childrenAlarms[i] + ".:_alert_hdl.._type", alertType);
      }

      if (alertType == DPCONFIG_NONE)
      {
        dynAppend(sources, childrenAlarms[i] + "." + prioRangeName);
      }
      else
      {
        dynAppend(sources, childrenAlarms[i] + ".");
      }
    }

    return sources;
  }

  /**
    _panel_param holds the parameters without the leading '$' the catalog
    stores them with.
  */
  private dyn_string alertPanelParameters(shared_ptr<NavigationTarget> target)
  {
    dyn_string parameters = target.getPanelParameters();
    dyn_string alertParameters;

    for (int i = 1; i <= dynlen(parameters); i++)
    {
      string parameter = parameters[i];

      if (parameter == "")
      {
        continue;
      }

      if (substr(parameter, 0, 1) == "$")
      {
        parameter = substr(parameter, 1);
      }

      dynAppend(alertParameters, parameter);
    }

    return alertParameters;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private static shared_ptr<AreaManager> areaManager = nullptr;
  private mapping areas;
  private mapping users;
  private shared_ptr<NavigationCatalog> navigationCatalog = nullptr;
  private dyn_string areaTypes = makeDynString("Lymata", "Lymata_S7Plus");
  private string userTypes = "UserPermissions";
  private const string USER_AREAS_ELEMENT = "Areas";
  private const string USER_PERMISSIONS_ELEMENT = "Permissions";
  private const string SUM_ALERT_MASTER_DP = "_mp__SumAlertPanel";
  private const string SUM_ALERT_DP_PREFIX = "SumAlert_";
};
