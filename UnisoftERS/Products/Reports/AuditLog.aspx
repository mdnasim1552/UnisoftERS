<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Reports.Master" CodeBehind="AuditLog.aspx.vb" Inherits="UnisoftERS.AuditLogReports" %>

<%@ Register assembly="Microsoft.ReportViewer.WebForms" namespace="Microsoft.Reporting.WebForms" tagprefix="rsweb" %>
<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    
    <telerik:RadFormDecorator ID="MultiPageSystemDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
    <div class="otherDataHeading">Audit log</div>

    <asp:Panel ID="ContentPanel" runat="server" Style="padding-left: 1em;" ScrollBars="Vertical" Height="627px">
        <div id="ContentDiv">
            <div class="optionsBodyText" id="NEDForm">
                <div>
                    <fieldset style="width: 765px; padding: 15px;">
                        <legend>Filter by...</legend>
                        <div class="divTable">
                            <div class="divTableBody">
                                <div class="divTableRow">
                                    <div class="divTableCell">
                                        <span class="divTableCell">
                                            <telerik:RadDatePicker ID="RDPFrom" runat="server" Culture="en-GB" ToolTip="First date to be used in the report" Skin="Web20" MinDate="01/01/2000" MaxDate="01/01/3500">
                                                <DateInput DateFormat="dd/MM/yyyy" DisplayDateFormat="dd/MM/yyyy" EmptyMessage="Date from" />
                                            </telerik:RadDatePicker>
                                        </span>
                                        <span class="divTableCell" style="padding-left: 30px;">
                                            <telerik:RadDatePicker ID="RDPTo" runat="server" Culture="en-GB" ToolTip="To date to be used in the report" Skin="Web20" MinDate="01/01/2000" MaxDate="01/01/3500">
                                                <DateInput DateFormat="dd/MM/yyyy" DisplayDateFormat="dd/MM/yyyy" EmptyMessage="Date to" />
                                            </telerik:RadDatePicker>
                                        </span>
                                        <div style="padding-top: 10px;"></div>
                                        <div>
                                            <telerik:RadTextBox ID="txtDescription" runat="server" Skin="Web20" EmptyMessage="Description" Width="100%" />
                                        </div>
                                    </div>
                                    <div class="divTableCell" style="width: 100%;">
                                        <asp:CompareValidator ID="dateCompareValidator" runat="server" ControlToValidate="RDPTo" ControlToCompare="RDPFrom" Operator="GreaterThan" ValidationGroup="FilterGroup" Type="Date" ErrorMessage="The second date must be after the first one." SetFocusOnError="True" ForeColor="Red" />
                                    </div>
                                    <div class="divTableCell" style="width: 100%; text-align: right; padding-right: 20px;">
                                        <telerik:RadButton ID="PreviewButton" runat="server" Text="Preview" Skin="Silk"
                                            CausesValidation="false" Icon-PrimaryIconCssClass="telerikPreviewButton" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </fieldset>
                </div>
                <br style="clear: both;" />
            </div>
            <div class="optionsBodyText" id="divAuditRep">

                <rsweb:ReportViewer ID="RV" runat="server" Font-Names="Verdana" Font-Size="8pt" WaitMessageFont-Names="Verdana" WaitMessageFont-Size="14pt" SizeToReportContent="true" CssClass="RVcss" >
                    <LocalReport ReportEmbeddedResource="UnisoftERS.ERS_Rep_AuditLog.rdlc">
                    </LocalReport>
                </rsweb:ReportViewer>
            </div>
        </div>
    </asp:Panel>

        <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">

            $(document).ready(function () {
            });
        </script>
    </telerik:RadScriptBlock>

</asp:Content>