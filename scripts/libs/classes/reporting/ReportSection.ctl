// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/StationReport"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  One numbered section of a report, typically one signal across many stations.
*/
class ReportSection
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportSection(int number, string title)
  {
    this.number = number;
    this.title = title;
  }

  public int getNumber()
  {
    return this.number;
  }

  public string getTitle()
  {
    return this.title;
  }

  public void addStation(shared_ptr<StationReport> station)
  {
    if (station == nullptr)
      return;

    dynAppend(stations, station);
  }

  public dyn_anytype getStations()
  {
    return this.stations;
  }

  public mapping toMapping()
  {
    mapping json;
    dyn_anytype stationMaps;

    for (int i = 1; i <= dynlen(stations); i++)
    {
      shared_ptr<StationReport> station = stations[i];
      dynAppend(stationMaps, station.toMapping());
    }

    json["number"] = this.number;
    json["title"] = this.title;
    json["stations"] = stationMaps;
    return json;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private int number;
  private string title;
  private dyn_anytype stations;
};
