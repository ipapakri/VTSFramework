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
  One section's datapoint suffix relative to a station DP, and the provider
  that knows how to turn that DPE into events.
*/
class ReportSignal
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportSignal(string suffix, string providerKey)
  {
    this.suffix = suffix;
    this.providerKey = providerKey;
  }

  public string getSuffix()
  {
    return this.suffix;
  }

  public string getProviderKey()
  {
    return this.providerKey;
  }

  /**
    Station DP plus the configured suffix. A suffix that is already a full
    DPE is returned unchanged.
  */
  public string resolveDpe(string stationDp)
  {
    if (this.suffix == "")
      return stationDp;

    if (strpos(this.suffix, ".") == 0 || strpos(this.suffix, ":") >= 0)
      return stationDp + this.suffix;

    return stationDp + "." + this.suffix;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private string suffix;
  private string providerKey;
};
