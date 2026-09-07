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
class MapObject
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public MapObject(string lat, string lon, string dp, string cnsPath)
  {
    this.lat = lat;
    this.lon = lon;
    this.dp = dp;
    this.cnsPath = cnsPath;
  }

  public void setLat(string lat)
  {
    this.lat = lat;
  }

  public string getLat()
  {
    return this.lat;
  }

  public void setLon(string lon)
  {
    this.lon = lon;
  }

  public string getLon()
  {
    return this.lon;
  }

  public void setDp(string dp)
  {
    this.dp = dp;
  }

  public string getDp()
  {
    return this.dp;
  }

  public void setCnsPath(string cnsPath)
  {
    this.cnsPath = cnsPath;
  }

  public string getCnsPath()
  {
    return this.cnsPath;
  }

  public string getCoordinates()
  {
    return lat + ", " + lon;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private string lat;
  private string lon;
  private string dp;
  private string cnsPath;
};
