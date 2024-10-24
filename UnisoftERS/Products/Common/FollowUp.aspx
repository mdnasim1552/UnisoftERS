<%--*************************************************************************************************************************--%>
<%--***********************************************THIS PAGE IS NOT BEING USED***********************************************--%>
<%--*************************************************************************************************************************--%>

<%@ Page Title="" Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_FollowUp" Codebehind="FollowUp.aspx.vb" %>
<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="FUHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
</asp:Content>
<asp:Content ID="FUBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
<div id="cmdOtherData" style="margin: 10px 10px;">
    <div>
        <asp:CheckBox ID="chkNoFurtherTests" runat="server" Text="No further tests" Font-Bold="true" />
        <asp:CheckBox ID="CheckBox1" runat="server" Text="Awaiting pathology results" Font-Bold="true" />
    </div>
    <div style="margin: 10px 10px;">
        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="Metro" Orientation="HorizontalTop" RenderMode="Lightweight">
            <Tabs>                                
                <telerik:RadTab Text="Further procedure(s)" />
                <telerik:RadTab Text="Follow Up" />
                <telerik:RadTab Text="Advice/Comments" />   
                <telerik:RadTab Text="Copy to / Salutation" />
            </Tabs>
        </telerik:RadTabStrip>
        <telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">
            <telerik:RadPageView ID="pageCancerScreening" runat="server">
                <div style="margin: 10px 10px; color: #000000;">
                    <table id="table3" runat="server" cellspacing="0" cellpadding="0">
                        <tr>
                            <td style="width: 270px;">Further procedures:&nbsp;<telerik:RadComboBox ID="RadComboBox2" runat="server" Width="140" Skin="Windows7" /></td>
                            <td>in&nbsp;<telerik:RadNumericTextBox CssClass="spinAlign" ID="RadNumericTextBox2" runat="server" NumberFormat-DecimalDigits="0" ShowSpinButtons="true" Width="50" Skin="Office2007" /></td>
                            <td>&nbsp;<telerik:RadComboBox ID="RadComboBox3" runat="server" Width="70" Skin="Windows7" /></td>
                            <td>&nbsp;<telerik:RadButton ID="RadButton2" runat="server" Text="Add" Skin="Office2007" /></td>
                        </tr>
                        <tr>
                            <td colspan="4" style="height: 20px;"><i>(Max 255 characters)</i></td>
                        </tr>
                        <tr>
                            <td colspan="4">
                                <telerik:RadTextBox ID="RadTextBox8" runat="server" Width="450" Height="100" MaxLength="255" TextMode="MultiLine" Skin="Office2007" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4" style="height: 30px;">
                                <telerik:RadButton ID="RadButton3" runat="server" Text="Phrase library" Skin="Office2007" />
                            </td>
                        </tr>
                    </table>
                </div>
            </telerik:RadPageView>



            <telerik:RadPageView ID="pageFurtherProcs" runat="server">
                <div style="margin: 10px 10px; color: #000000;">
                    <table id="tableFurtherProcs" runat="server" cellspacing="0" cellpadding="0">
                        <tr>
                            <td style="width: 270px;">Further procedures:&nbsp;<telerik:RadComboBox ID="cboFurtherProcs" runat="server" Width="140" Skin="Windows7" /></td>
                            <td>in&nbsp;<telerik:RadNumericTextBox CssClass="spinAlign" ID="RadNumericTextBox3" runat="server" NumberFormat-DecimalDigits="0" ShowSpinButtons="true" Width="50" Skin="Office2007" /></td>
                            <td>&nbsp;<telerik:RadComboBox ID="cboReviewPeriod" runat="server" Width="70" Skin="Windows7" /></td>
                            <td>&nbsp;<telerik:RadButton ID="cmdAdd" runat="server" Text="Add" Skin="Office2007" /></td>
                        </tr>
                        <tr>
                            <td colspan="4" style="height: 20px;"><i>(Max 255 characters)</i></td>
                        </tr>
                        <tr>
                            <td colspan="4">
                                <telerik:RadTextBox ID="RadTextBox1" runat="server" Width="450" Height="100" MaxLength="255" TextMode="MultiLine" Skin="Office2007" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4" style="height: 30px;">
                                <telerik:RadButton ID="cmdPhrase" runat="server" Text="Phrase library" Skin="Office2007" />
                            </td>
                        </tr>
                    </table>
                </div>
            </telerik:RadPageView>
            <telerik:RadPageView ID="pageFollowUp" runat="server">
                <div style="margin: 10px 10px; color: #000000;">
                    <table id="tableFollowUp" runat="server" cellspacing="3" cellpadding="0" border="0">
                        <tr>
                            <td style="width: 130px;">Return to the</td>
                            <td><telerik:RadComboBox ID="cboReturnTo" runat="server" Width="140" Skin="Windows7" /></td>
                            <td></td>
                            <td></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td>No further follow up</td>
                            <td><asp:CheckBox ID="CheckBox2" runat="server" /></td>
                            <td></td>
                            <td></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td>Review will be in the</td>
                            <td>
                                <telerik:RadComboBox ID="RadComboBox1" runat="server" Width="140" Skin="Windows7" />
                            </td>
                            <td>&nbsp;in&nbsp;
                                <telerik:RadNumericTextBox runat="server" CssClass="spinAlign"
                                    ID="RadNumericTextBox1"
                                    MaxValue="31" 
                                    MaxLength="2" 
                                    NumberFormat-DecimalDigits="0" 
                                    ShowSpinButtons="true" 
                                    Width="50" 
                                    Skin="Office2007"/>
                            </td>

                            <td>&nbsp;<telerik:RadComboBox ID="cboReviewIn" runat="server" Width="70" Skin="Windows7" />
                            </td>
                            <td>&nbsp;<telerik:RadButton ID="RadButton1" runat="server" Text="Add" Skin="Office2007" />
                            </td>
                        </tr>
                        <tr>
                            <td><i>(Max 255 characters)</i></td>
                            <td colspan="4"><telerik:RadTextBox ID="RadTextBox2" runat="server" Width="320" Height="100" MaxLength="255" TextMode="MultiLine" Skin="Office2007" /></td>
                        </tr>
                    </table>
                    <asp:RangeValidator id="RadNumericTextBoxRangeValidator"
                                        ControlToValidate="RadNumericTextBox1"
                                        MinimumValue="0"
                                        MaximumValue="31"
                                        Type="Integer"
                                        EnableClientScript="false"
                                        Text="The value must be from 1 to 31"
                                        runat="server"/>
                </div>
            </telerik:RadPageView>
            <telerik:RadPageView ID="pageAdviceComments" runat="server">
                <div class="rptSummaryText10" style="margin: 10px 10px;">
                    <table id="table1" runat="server" cellspacing="0" cellpadding="0" border="0">
                        <tr>
                            <td>Advice or comments are printed at the end of the report</td>
                        </tr>
                        <tr>
                            <td><telerik:RadTextBox ID="RadTextBox3" runat="server" Height="100" Width="500" MaxLength="500" TextMode="MultiLine" Skin="Office2007" /></td>
                        </tr>
                        <tr>
                            <td></td>
                        </tr>
                    </table>               
                </div>
            </telerik:RadPageView>
            <telerik:RadPageView ID="pageCopyTo" runat="server">
                <div class="rptSummaryText10" style="margin: 10px 10px;">
                    <table id="table2" runat="server" cellspacing="0" cellpadding="1" border="0">
                        <tr>
                            <td><asp:RadioButton ID="RadioButton1" runat="server" Text="Patient" GroupName="optCopyTo" /></td>
                            <td><telerik:RadTextBox ID="RadTextBox4" runat="server" Width="250" Skin="Office2007" /></td>
                        </tr>
                        <tr>
                            <td><asp:RadioButton ID="RadioButton2" runat="server" Text="Patient not copied (reason)" GroupName="optCopyTo" />&nbsp;&nbsp;</td>
                            <td><telerik:RadTextBox ID="RadTextBox5" runat="server" Width="250" Skin="Office2007" /></td>
                        </tr>
                        <tr>
                            <td><asp:CheckBox ID="CheckBox32" runat="server" Text="Referring consultant" /></td>
                            <td><telerik:RadComboBox ID="RadComboBox5" runat="server" Skin="Windows7" Width="250" /></td>
                        </tr>
                        <tr>
                            <td><asp:CheckBox ID="CheckBox3" runat="server" Text="Other" /></td>
                            <td><telerik:RadTextBox ID="RadTextBox6" runat="server" Width="250" Skin="Office2007" /></td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 10px;"></td>
                        </tr>
                        <tr>
                            <td><b>Salutation</b></td>
                            <td><telerik:RadTextBox ID="RadTextBox7" runat="server" Width="250" Skin="Office2007" /></td>
                        </tr>
                    </table>          
                </div>
            </telerik:RadPageView>
        </telerik:RadMultiPage>
    </div>
    <div style="margin: 15px 15px;">
        <telerik:RadButton ID="cmdAccept" runat="server" Text="Accept" Skin="Web20" />
        <telerik:RadButton ID="cmdCancel" runat="server" Text="Cancel" Skin="Web20" OnClick="cancelRecord" />
    </div>
</div>
</asp:Content>

