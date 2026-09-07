// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/navigation/commands/NavigationCommand"
#uses "classes/navigation/MapNavigator"


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
*/
class ZoomToPointCommand : NavigationCommand
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ZoomToPointCommand(shared_ptr<MapNavigator> mapNavigator,
                            float latitude,
                            float longitude,
                            float altitude)
  {
    this.mapNavigator = mapNavigator;
    this.latitude = latitude;
    this.longitude = longitude;
    this.altitude = altitude;
  }

  public bool execute()
  {
    if (!mapNavigator)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "ZoomToPointCommand.ctl");
      return false;
    }

    return mapNavigator.zoomToPoint(this.latitude, this.longitude, this.altitude);
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private shared_ptr<MapNavigator> mapNavigator;
  float latitude;
  float longitude;
  float altitude;
};
