// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportPeriod"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  What to print: a stored definition, the stations to include, and the period.
*/
class ReportRequest
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportRequest(string definitionId)
  {
    this.definitionId = definitionId;
  }

  public string getDefinitionId()
  {
    return this.definitionId;
  }

  public void setStations(dyn_string stationDps)
  {
    this.stationDps = stationDps;
  }

  public dyn_string getStationDps()
  {
    return this.stationDps;
  }

  public void setPeriod(shared_ptr<ReportPeriod> period)
  {
    this.period = period;
  }

  public shared_ptr<ReportPeriod> getPeriod()
  {
    return this.period;
  }

  public void setUser(string user)
  {
    this.user = user;
  }

  public string getUser()
  {
    return this.user;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private string definitionId;
  private dyn_string stationDps;
  private shared_ptr<ReportPeriod> period;
  private string user;
};
