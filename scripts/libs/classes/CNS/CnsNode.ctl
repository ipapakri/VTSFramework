// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
*/
class CnsNode
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public CnsNode()
  {
  }

  public void setCnsPath(string cnsPath)
  {
    this.cnsPath = cnsPath;
  }

  public string getCnsPath()
  {
    return this.cnsPath;
  }

  public void setLabel(string label)
  {
    this.label = label;
  }

  public string getLabel()
  {
    return this.label;
  }

  public void setDp(string dp)
  {
    this.dp = dp;
  }

  public string getDp()
  {
    return this.dp;
  }

  public void setHasLocation(bool hasLocation)
  {
    this.hasLocation = hasLocation;
  }

  public bool getHasLocation()
  {
    return this.hasLocation;
  }

  public void setLat(float lat)
  {
    this.lat = lat;
  }

  public float getLat()
  {
    return this.lat;
  }

  public void setLon(float lon)
  {
    this.lon = lon;
  }

  public float getLon()
  {
    return this.lon;
  }

  public void setAlt(float alt)
  {
    this.alt = alt;
  }

  public float getAlt()
  {
    return this.alt;
  }

  public void setPanelFile(string panelFile)
  {
    this.panelFile = panelFile;
  }

  public string getPanelFile()
  {
    return this.panelFile;
  }

  public void setPanelParameters(dyn_string panelParameters)
  {
    this.panelParameters = panelParameters;
  }

  public dyn_string getPanelParameters()
  {
    return this.panelParameters;
  }

  public void setChildren(dyn_anytype children)
  {
    this.children = children;
  }

  public dyn_anytype getChildren()
  {
    return this.children;
  }

  public void addChild(shared_ptr<CnsNode> child)
  {
    dynAppend(this.children, child);
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private string cnsPath;
  private string label;
  private string dp;

  private bool hasLocation;
  private float lat;
  private float lon;
  private float alt;

  private string panelFile;
  private dyn_string panelParameters;

  private dyn_anytype children;
};
