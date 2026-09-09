// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/CNS/CnsNode.ctl"
//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
*/
class CnsRepository
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public CnsRepository()
  {
  }

  public shared_ptr<CnsNode> loadView(string viewPath)
  {
    if (!normalizeCnsViewPath(viewPath))
    {
      DebugN("Invalid CNS view path:", viewPath);
      return nullptr;
    }

    dyn_string cnsTrees;

    if (!cnsGetTrees(viewPath, cnsTrees))
    {
      DebugN("Could not read CNS view:", viewPath);
      return nullptr;
    }

    // The root is a synthetic node representing the CNS view itself.
    shared_ptr<CnsNode> root = new CnsNode();

    root.setCnsPath(viewPath);
    root.setLabel(getCnsViewLabel(viewPath));

    for (int i = 1; i <= dynlen(cnsTrees); i++)
    {
      shared_ptr<CnsNode> child = loadNode(cnsTrees[i]);

      if (child != nullptr)
        root.addChild(child);
    }

    return root;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
//------------------------------------------------------------------------------

  /**
   * Recursively loads one CNS node and all of its children.
   */
  private shared_ptr<CnsNode> loadNode(string cnsPath)
  {
    shared_ptr<CnsNode> node = new CnsNode();

    node.setCnsPath(cnsPath);
    node.setLabel(getCnsNodeLabel(cnsPath));

    // Resolve the DP associated with the CNS node.
    string dp;
    cnsGetId(cnsPath, dp);
    node.setDp(dp);
    dyn_string keys;

    if(dpExists(node.getDp()))
    {

      string lat, lon, alt, panelFile;
      dpGet(node.getDp() + ".Internal.lat", lat,
            node.getDp() + ".Internal.lon", lon,
            node.getDp() + ".Internal.alt", alt,
            node.getDp() + ".Internal.panelFileName", panelFile);

      node.setLat(lat);
      node.setLon(lon);
      node.setAlt(alt);
      node.setPanelFile(panelFile);
      node.setPanelParameters(makeDynString("$DP:" + node.getDp()));

      if(node.getLat() != "" && node.getLon() != "" && node.getAlt() != "")
      {
        node.setHasLocation(true);
      }
    }
    // Recursively load children.
    dyn_string children;

    if (cnsGetChildren(cnsPath, children))
    {
      for (int i = 1; i <= dynlen(children); i++)
      {
        shared_ptr<CnsNode> child = loadNode(children[i]);

        if (child != nullptr)
          node.addChild(child);
      }
    }



    return node;
  }

  /**
   * Adds the trailing colon when only a view name/path was supplied.
   *
   * Accepted:
   *   ".Sites"
   *   ".Sites:"
   *   "System1.Sites"
   *   "System1.Sites:"
   */
  private bool normalizeCnsViewPath(string &viewPath)
  {
    viewPath.trim();

    if (viewPath == "")
      return false;

    if (substr(viewPath, strlen(viewPath) - 1, 1) != ":")
      viewPath += ":";

    return true;
  }

  /**
   * Returns the display name of a CNS view in the currently active project
   * language.
   */
  private string getCnsViewLabel(string viewPath)
  {
    langString displayNames;

    if (cnsGetViewDisplayNames(viewPath, displayNames))
    {
      string label = displayNames.text();

      if (label != "")
        return label;
    }

    return getTechnicalViewName(viewPath);
  }

  /**
   * Returns the display name of a CNS node in the currently active project
   * language.
   */
  private string getCnsNodeLabel(string cnsPath)
  {
    langString displayNames;

    if (cnsGetDisplayNames(cnsPath, displayNames))
    {
      string label = displayNames.text();

      if (label != "")
        return label;
    }

    return getTechnicalNodeName(cnsPath);
  }

  /**
   * Extracts the technical view name.
   *
   * Examples:
   *
   *   ".Sites:"        -> "Sites"
   *   "System1.Sites:" -> "Sites"
   */
  private string getTechnicalViewName(string viewPath)
  {
    string name = viewPath;

    // Remove trailing colon.
    if (strlen(name) > 0 &&
        substr(name, strlen(name) - 1, 1) == ":")
    {
      name = substr(name, 0, strlen(name) - 1);
    }

    int dotPos = strrpos(name, ".");

    if (dotPos >= 0)
      return substr(name, dotPos + 1);

    return name;
  }


  //------------------------------------------------------------------------------
  /**
   * Extracts the final technical node name from a standard CNS ID path.
   *
   * Examples:
   *   ".Sites:Europe"                 -> "Europe"
   *   ".Sites:Europe.Austria.Vienna" -> "Vienna"
   */
  private string getTechnicalNodeName(string cnsPath)
  {
    int colonPos = strpos(cnsPath, ":");

    if (colonPos < 0)
      return cnsPath;

    string nodePart = substr(cnsPath, colonPos + 1);
    int dotPos = strrpos(nodePart, ".");

    if (dotPos >= 0)
      return substr(nodePart, dotPos + 1);

    return nodePart;
  }
};
