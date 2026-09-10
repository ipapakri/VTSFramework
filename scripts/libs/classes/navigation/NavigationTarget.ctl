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
  Destination resolved by a catalog. Views use only the fields they understand.
  Missing location or panel is a no-op for that view, not a failed navigation.
*/
class NavigationTarget
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public NavigationTarget()
  {
  }

  public bool hasPanel()
  {
    return panelFile != "";
  }

  public void setId(string id)
  {
    this.id = id;
  }

  public string getId()
  {
    return this.id;
  }

  public void setLabel(string label)
  {
    this.label = label;
  }

  public string getLabel()
  {
    return this.label;
  }

  public void setDatapoint(string datapoint)
  {
    this.datapoint = datapoint;
  }

  public string getDatapoint()
  {
    return this.datapoint;
  }

  public void setHasLocation(bool hasLocation)
  {
    this.hasLocation = hasLocation;
  }

  public bool getHasLocation()
  {
    return this.hasLocation;
  }

  public void setLatitude(float latitude)
  {
    this.latitude = latitude;
  }

  public float getLatitude()
  {
    return this.latitude;
  }

  public void setLongitude(float longitude)
  {
    this.longitude = longitude;
  }

  public float getLongitude()
  {
    return this.longitude;
  }

  public void setAltitude(float altitude)
  {
    this.altitude = altitude;
  }

  public float getAltitude()
  {
    return this.altitude;
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

  public void setExtras(mapping extras)
  {
    this.extras = extras;
  }

  public mapping getExtras()
  {
    return this.extras;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private string id;
  private string label;
  private string datapoint;

  private bool hasLocation;
  private float latitude;
  private float longitude;
  private float altitude;

  private string panelFile;
  private dyn_string panelParameters;

  private mapping extras;
};
