// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "ptnavi"
#uses "ptms"
#uses "classes/AreaManagement/Area"
#uses "classes/AreaManagement/UserClass"

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
    systemName = getSystemName();
    strreplace(systemName, ":", "");
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
    return this.users[userName].hasPermission(areaDp, permission);
  }

  public mapping getAreasForUser(string userName)
  {
    return users[userName].getAreas();
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

  private void generateUserSumAlerts(string userName)
  {
    processNode(1, userName);
  }

  private string processNode(int i, string userName)
  {
    // Leaf
    dyn_string children = ptnavi_navigation[ systemName ][ ptnavi_CHILDREN ][i];
    string dp = "";
    if (dynlen(children) == 0)
    {
      string parameterString = ptnavi_navigation[ systemName ][ ptnavi_PARAMETERS ][i];
      if (parameterString == "")
      {
        return "";
      }
      dyn_string parameters = strsplit(parameterString, "$");
      dp = parameters[2];
      strreplace(dp, "DP:", "");

      if(areaManager.userHasPermission(userName, dp, 0))
      {
        return dp + ".";
      }
      else
      {
        return "";
      }
    }

    dyn_string childrenAlarms;

    for (int j = 1; j <=dynlen(children); j++)
    {
      string childAlarm = processNode(children[j], userName);
      if (childAlarm != "")
      {
        dynAppend(childrenAlarms, childAlarm);
      }
    }

    if (dynlen(childrenAlarms) == 0)
    {
      return "";
    }

    int iError;
    string dpName = ptnavi_navigation[ systemName ][ ptnavi_SUMALERTPANEL ][i] + "_" + userName;
    if(!dpExists(dpName))
    {
      dpCopy("_mp__SumAlertPanel", dpName, iError);
    }
    else
    {
      int iMp;
      dyn_string dsMpDpe = dpNames("_mp__SumAlertPanel.*");

      for ( iMp = 1; iMp <= dynlen(dsMpDpe); iMp++)
      {
        string s = dsMpDpe[iMp];
        int iAlertType;
        strreplace(s, dpSubStr(dsMpDpe[iMp],DPSUB_DP), dpName);
        dpGet(s + ":_alert_hdl.._type", iAlertType);  // check if there is already a sumalert
        if ( iAlertType != DPCONFIG_SUM_ALERT)
        {
          //DebugTN(__FUNCTION__, __LINE__, dpSubStr(dsMpDpe[iMp],DPSUB_DP_EL), dpName,makeDynString("_alert_hdl"), iError);
          dpCopyConfig(dpSubStr(dsMpDpe[iMp],DPSUB_DP_EL), dpName,makeDynString("_alert_hdl"), iError);
        }
      }
    }

    if (iError)
    {
      throwError(makeError("", PRIO_INFO, ERR_SYSTEM, 0, "pt_generateSumAlerts:::dpCopy:::iError "+iError+" ( _mp__SumAlertPanel -> "+dpName+" )"));
    }

    dyn_int        prioMin, prioMax;
    dyn_string     prioRange;
    dyn_string     defaultDps=makeDynString(getSystemName()+"_TmpBitAlert.");
    dyn_string     parameters = ptnavi_navigation[ systemName ][ ptnavi_PARAMETERS ][i];
    string         panel = ptnavi_navigation[ systemName ][ ptnavi_FILENAME ][i];
    dyn_langString dlOn,dlOff;
    unsigned       uAckHasPrio,uOrder;
    int            aType;

    dpGet("_SumAlertGeneral.prioRange.name:_online.._value",    prioRange,
          "_SumAlertGeneral.prioRange.min:_online.._value",     prioMin,
          "_SumAlertGeneral.prioRange.max:_online.._value",     prioMax,
          "_SumAlertGeneral.prioRange.textOn:_online.._value",  dlOn,
          "_SumAlertGeneral.prioRange.textOff:_online.._value", dlOff,
          "_SumAlertGeneral.ack_has_prio:_online.._value",      uAckHasPrio,
          "_SumAlertGeneral.order:_online.._value",             uOrder);

    for (int j=1;j<=dynlen(prioRange);j++)
    {
      dyn_string prioRangeChildrenAlarms = childrenAlarms;
      for(int k=1; k<=dynlen(prioRangeChildrenAlarms); k++)
      {
        anytype val;
        if(dpExists(prioRangeChildrenAlarms[k] + ":_alert_hdl.._type"))
        {
          dpGet(prioRangeChildrenAlarms[k] + ":_alert_hdl.._type", val);
        }
        else if(dpExists(prioRangeChildrenAlarms[k] + ".:_alert_hdl.._type"))
        {
          dpGet(prioRangeChildrenAlarms[k] + ".:_alert_hdl.._type", val);
        }
        if(val == DPCONFIG_NONE)
        {
          prioRangeChildrenAlarms[k] = prioRangeChildrenAlarms[k] + "." + prioRange[j];
        }
      }
      string dpe=dpName+"."+prioRange[j];
      dpGet(dpe+":_alert_hdl.._type",aType);

      if ( aType != DPCONFIG_SUM_ALERT )
      {
        dpSetTimed(0L,dpe+":_alert_hdl.._type",DPCONFIG_SUM_ALERT); // IM 106203
        dpSetTimed(0L,dpe+":_alert_hdl.._text1",dlOn[j],
                dpe+":_alert_hdl.._text0",dlOff[j],
                dpe+":_alert_hdl.._class","",
                dpe+":_alert_hdl.._ack_has_prio",uAckHasPrio,
                    dpe+":_alert_hdl.._order",2,//uOrder,
                    dpe+":_alert_hdl.._dp_list",makeDynString("_TmpBitAlert."),
                    dpe+":_alert_hdl.._dp_pattern","",
                    dpe+":_alert_hdl.._prio_pattern",prioMin[j]+"-"+prioMax[j],
                    dpe+":_alert_hdl.._abbr_pattern","",
                    dpe+":_alert_hdl.._ack_deletes",true,
                    dpe+":_alert_hdl.._non_ack",true,
                    dpe+":_alert_hdl.._came_ack",true,
                    dpe+":_alert_hdl.._pair_ack",true,
                    dpe+":_alert_hdl.._both_ack",true,
                    dpe+":_alert_hdl.._panel","",
                    dpe+":_alert_hdl.._panel_param",makeDynString(),
                    dpe+":_alert_hdl.._help",ls_lt);
        }

        bool ok;
        dpDeactivateAlert( dpe, ok, true);

        dpSetTimed(0L,dpe+":_alert_hdl.._dp_list",(dynlen(prioRangeChildrenAlarms)>0)?prioRangeChildrenAlarms:defaultDps, // IM 106203
                    dpe+":_alert_hdl.._panel",panel,
                    dpe+":_alert_hdl.._panel_param",strsplit(parameters,"$"),
                    dpe+":_alert_hdl.._prio_pattern",prioMin[j]+"-"+prioMax[j],
                    dpe+":_alert_hdl.._ack_has_prio",uAckHasPrio,
                    dpe+":_alert_hdl.._order",uOrder);

        dpActivateAlert( dpe, ok, true);
      }

    return ptnavi_navigation[ systemName ][ ptnavi_SUMALERTPANEL ][i] + "_" + userName;
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
  private dyn_string areaTypes = makeDynString("Lymata", "Lymata_S7Plus");
  private string userTypes = "UserPermissions";
  private const string USER_AREAS_ELEMENT = "Areas";
  private const string USER_PERMISSIONS_ELEMENT = "Permissions";
  private string systemName;
};
