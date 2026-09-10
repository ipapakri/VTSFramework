// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/Map/MapObject"
#uses "classes/navigation/NavigationCatalog"
#uses "classes/navigation/NavigationTarget"
#uses "classes/navigation/NavigationView"


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Map surface. mapWidget should be the Map EWO (the object that provides centerOn).
*/
class MapNavigator : NavigationView
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  public static shared_ptr<MapNavigator> instance(string moduleName)
  {
    if (moduleName == "")
    {
      return nullptr;
    }

    if(!mappingHasKey(instances, moduleName))
    {
      instances[moduleName] = new MapNavigator(moduleName);
    }

    return instances[moduleName];
  }

  /**
    @brief Drops the navigator registered for moduleName.
    @details Call from the owning panel's Terminate: the navigator holds shape
    handles that die with the panel.
  */
  public static void release(string moduleName)
  {
    if (mappingHasKey(instances, moduleName))
    {
      mappingRemove(instances, moduleName);
    }
  }

  /**
    @brief The function sets the shape of the Map EWO.
    @param shapeMap The given shape of the Map EWO.
  */
  public void setMapWidget(shape mapWidget)
  {
    this.mapWidget = mapWidget;
  }

  /**
    @brief The function returns the shape of the Map EWO.
    @return shape mainMap The shape of the Map EWO.
  */
  public shape getMapWidget()
  {
    return this.mapWidget;
  }

  /**
    @brief The function returns the map object registered for the given name.
    @param name The object name.
    @return The map object, or nullptr if the object is not found.
  */
  public shared_ptr<MapObject> getMapObject(string name)
  {
    if ( mappingHasKey(mapObjects, name) )
      return mapObjects[name];

    return nullptr;
  }

    public shape getMapModule()
  {
    return this.mapModule;
  }

  public void setMapModule(shape mapModule)
  {
    this.mapModule = mapModule;
  }

  /**
    @brief This is a main routine for centering a view on a location on the Map EWO.
    @details The function moves the view to the provided location with the given coordinates or
    if no coordinates are specified back home.
    @param coordinates Location of the point where the map should be centered. If not specified,
    the home coordinates will be used.
  */
  public void goThere(const string coordinates = "")
  {
    if ( !waitForReady() )
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Map is not ready, cannot center on", coordinates);
      return;
    }

    shape mapShape = mapWidget;

    if ( !mapShape )
      return;

    float maxAlt = 3100;
    mapping props = getMapThemeProperties(mapShape.mapThemeId());

    // Define altitude based on map theme maximum zoom
    if ( props["zoom"]["maximum"] < maxAlt / 2.0 )
      maxAlt = 1060183;
    else if ( props["zoom"]["maximum"] <  maxAlt )
      maxAlt = 60000;

    if ( coordinates == "" )
      mapShape.centerOn(getHomeCoordinates(), getHomeZoom());  // center on home
    else
      mapShape.centerOn(coordinates, maxAlt);
  }

  /**
    @brief The function returns properties for a map theme as definied in its DGML file.
    @param  mapThemeId  ID of the map theme.
    @return mapping properties Properties for a given map theme. If a map theme is not
    found or another error occurs, the mapping is empty.
  */
  public mapping getMapThemeProperties(string mapThemeId)
  {
    mapping result;

    string dgmlFileName = getPath(DATA_REL_PATH, mapsRootDir + mapThemeId, 1, SEARCH_PATH_LEN);

    string xmlErrMsg;
    int xmlErrLine, xmlErrColumn;
    int docId = xmlDocumentFromFile(dgmlFileName, xmlErrMsg, xmlErrLine, xmlErrColumn);

    if ( docId >= 0 )
    {
      int headId = getNamedXmlElement(docId, makeDynString("dgml", "document", "head"));
      if ( headId >= 0 )
        result = getDgmlHeadValues(docId, headId);

      xmlCloseDocument(docId);
    }
    else
      DebugTN("DGML Error", xmlErrMsg, xmlErrLine, xmlErrColumn);

    if ( mappingHasKey(result, "icon") )
      result["icon"] = dirName(dgmlFileName) + result["icon"];  // get absolute path of icon pximap

    return result;
  }

  /**
    @brief The function returns the default coordinates.
    @return homeCoord The default coordinates.
  */
  public string getHomeCoordinates()
  {
    return homeCoord;
  }

  /**
    @brief This is a main routine for opening an information window for the Map EWO shapes.
    @details The function opens a child panel of the given size for the given name.
    @param name The name of the shape for which the child panel should be opened.
    @param x The horizontal size of the child panel. The default value is 100 px.
    @param y The vertical size of the child panel. The default value is 100 px.
    @param brief Checks weather the child panel should contain brief info.
    The default value is 1 meaning that the child panel contains brief information.
  */
  public static void showInfo(const string &name, const int x = 100, const int y = 100, int brief = 1)
  {
    //string panelName = "examples/maps/subPanels/briefInfo.pnl";
    string panelName = "objects/Parts/Pump_station_2P_Mimiko.pnl";
    if ( !brief )
      //panelName = "examples/maps/subPanels/fullInfo.pnl";
      panelName = "objects/Parts/Pump_station_2P_Mimiko.pnl";
    else if ( brief == 2 )
      panelName = "examples/maps/subPanels/message.pnl";

    dyn_anytype da = makeDynAnytype(myModuleName(),
                                    panelName,
                                    myPanelName(),
                                    "info",
                                    x,
                                    y,
                                    1.0,
                                    true,
                                    makeDynString("$DP:" + name, "$Number:1"),
                                    false,
                                    makeMapping("windowFlags", "Popup"));

    childPanel(da);
  }

  /**
    @brief The function sets data points for the Map demo.
    @param name The data point names that are set.
  */
  public void setDPEname(string name)
  {
    if ( !dynContains(allDPEnames, name) )
      dynAppend(allDPEnames, name);

    return;
  }

  /**
    @brief The function returns data points of the Map demo.
    @return dyn_string dps The data point names or -1 if a DPE does not exist.
  */
  public dyn_string getDPEnames()
  {
    if ( dpExists(allDPEnames[dynlen(allDPEnames)]) || !createDPE(allDPEnames) )
      return allDPEnames;
    else
      return makeDynString("-1");
  }

  /**
    @brief The function sets an object and its coordinates for the Map demo.
    @param name The object name.
    @param coordinate The object coordinates.
  */
  public void setMapObject(string name, shared_ptr<MapObject> coordinate)
  {
    mapObjects[name] = coordinate;
    setDPEname(name);

    return;
  }

  /**
    @brief The function returns the default zoom value.
    @return homeZoom The default zoom value.
  */
  public int getHomeZoom()
  {
    return homeZoom;
  }

  /**
    @brief Registers a map symbol for every catalog target that has a location.
  */
  public void populate(shared_ptr<NavigationCatalog> catalog)
  {
    if (catalog == nullptr)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Cannot populate map without a catalog");
      return;
    }

    dyn_string ids = catalog.getAllIds();

    for (int i = 1; i <= dynlen(ids); i++)
    {
      shared_ptr<NavigationTarget> target = catalog.resolve(ids[i]);

      if (target == nullptr || !target.getHasLocation())
        continue;

      setMapObject(
        target.getDatapoint(),
        new MapObject(
          target.getLatitude(),
          target.getLongitude(),
          target.getDatapoint(),
          target.getId()
        )
      );
    }
  }

  public bool apply(shared_ptr<NavigationTarget> target)
  {
    if (target == nullptr)
      return false;

    if (!target.getHasLocation())
      return true;

    // The EWO only exists once the map sub-panel has run. Hold the target and
    // let onReady() replay it rather than blocking the UI thread here.
    if (!this.getReady())
    {
      assignPtr(pendingTarget, target);
      return true;
    }

    return zoomToPoint(target.getLatitude(), target.getLongitude(), target.getAltitude());
  }

  public bool zoomToPoint(float latitude, float longitude, float altitude)
  {
    mapWidget.centerOn(latitude, longitude, altitude);
    return true;
  }

  public string getModuleName()
  {
    return this.moduleName;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

  /**
    @brief Replays the target that arrived while the map was still loading.
  */
  protected void onReady()
  {
    if ( pendingTarget == nullptr )
      return;

    shared_ptr<NavigationTarget> target;
    assignPtr(target, pendingTarget);
    pendingTarget = nullptr;

    apply(target);
  }

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  /**
    @brief Waits for the map sub-panel to report itself ready.
    @param timeoutMs Maximum time to wait, in milliseconds.
    @return bool ready True if the map became ready within the timeout.
  */
  private bool waitForReady(int timeoutMs = 10000)
  {
    int waited = 0;

    while ( !this.getReady() && waited < timeoutMs )
    {
      delay(0, 100);
      waited += 100;
    }

    return this.getReady();
  }

  /**
    @brief A helper function to return the ID of an XML element with a specified name hierarchy.
    @param  docId      ID of the XML document.
    @param  names      Hierarchical list of element names.
    @param  nameIndex  Index of the first name to check in names (used for recursion)
    @param  parentNode If specified, the search for the element starts from the child node of
    this parent node. Otherwise, the search is started from the document root.
    @return int id ID of the XML element or -1 if the XML element was not found.
  */
  static int getNamedXmlElement(int docId, dyn_string names, int nameIndex = 1, int parentNode = -1)
  {
    int nodeId = parentNode >= 0 ? xmlFirstChild(docId, parentNode) : xmlFirstChild(docId);

    while (nodeId >= 0)
    {
      if ( (xmlNodeType(docId, nodeId) == XML_ELEMENT_NODE) &&
           (xmlNodeName(docId, nodeId) == names[nameIndex]) )
      {
        if ( nameIndex == dynlen(names) )
          return nodeId;
        else
          return getNamedXmlElement(docId, names, ++nameIndex, nodeId);
      }

      nodeId = xmlNextSibling(docId, nodeId);
    }

    return -1;
  }

  /**
    @brief A helper function to return values from a DGML head element.
    @param  docId ID of the XML document.
    @param  headId ID of the head element.
    @return mapping values Values of the head element.
  */
  static mapping getDgmlHeadValues(int docId, int headId)
  {
    mapping result;
    dyn_uint propNodes;
    string value;

    if ( !xmlChildNodes(docId, headId, propNodes) )
    {
      for (int i = 1; i <= dynlen(propNodes); i++)
      {
        if ( xmlNodeType(docId, propNodes[i]) == XML_ELEMENT_NODE )
        {
          string name = xmlNodeName(docId, propNodes[i]);

          if ( name == "icon" )
          {
            // the icon element contains the name of the icon pixmap
            // in an attribute and therefore needs special treatment
            if ( !xmlGetElementAttribute(docId, propNodes[i], "pixmap", value) )
              result[name] = strltrim(strrtrim(value));
          }
          else
          {
            value = xmlNodeValue(docId, xmlFirstChild(docId, propNodes[i]));

            if ( strlen(value) > 0 )
              result[name] = strltrim(strrtrim(value));
            else
            {
              // node has no value, get child values recursively
              mapping childResult = getDgmlHeadValues(docId, propNodes[i]);
              if ( mappinglen(childResult) > 0 )
                result[name] = childResult;
            }
          }
        }
      }
    }

    return result;
  }

  private MapNavigator(string moduleName)
  {
    this.moduleName = moduleName;
  }

  private shape mapWidget;
  private shape mapModule;

  private shared_ptr<NavigationTarget> pendingTarget;

  private mapping mapObjects;
  private dyn_string allDPEnames;

  private string homeCoord = "37.981, 23.545";
  private int homeZoom = 25000;

  private string moduleName;

  private static mapping instances;
  private static string mapsRootDir = "marble/maps/";
};
