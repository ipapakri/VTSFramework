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
  Outcome of one generate() call. State values are shared with _ReportJob.
*/
class ReportResult
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  public static const int STATE_IDLE = 0;
  public static const int STATE_PENDING = 1;
  public static const int STATE_RUNNING = 2;
  public static const int STATE_DONE = 3;
  public static const int STATE_ERROR = 4;

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public ReportResult()
  {
    this.state = STATE_IDLE;
  }

  public bool isOk()
  {
    return this.state == STATE_DONE;
  }

  public void setOk(string pdfPath)
  {
    this.state = STATE_DONE;
    this.pdfPath = pdfPath;
    this.error = "";
  }

  public void setError(string error)
  {
    this.state = STATE_ERROR;
    this.error = error;
  }

  public void setState(int state)
  {
    this.state = state;
  }

  public int getState()
  {
    return this.state;
  }

  public void setPdfPath(string pdfPath)
  {
    this.pdfPath = pdfPath;
  }

  public string getPdfPath()
  {
    return this.pdfPath;
  }

  public string getError()
  {
    return this.error;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private int state;
  private string pdfPath;
  private string error;
};
