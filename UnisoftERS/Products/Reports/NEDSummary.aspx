<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Reports.Master" CodeBehind="NEDSummary.aspx.vb" Inherits="UnisoftERS.NEDSummary" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContentPlaceHolder2" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <script type="text/javascript" src="../../Scripts/Reports.js"></script>
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Width="500px" Height="200px"
        Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
        ForeColor="Red" Position="Center" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true" Width="100%">
    </telerik:RadAjaxLoadingPanel>

    <div id="Content">

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0"
            PanesBorderSize="0">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="100%">
                <asp:Panel ID="NoProceduresPanel" runat="server" Visible="false">
                </asp:Panel>
                <asp:Panel ID="ReportPanel" runat="server">
                    <div style="margin: 0px 10px; width: 95%;">
                        <div style="margin-top: 10px;"></div>
                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1"
                            SelectedIndex="0" Skin="Metro" RenderMode="Lightweight" Font-Size="Larger">
                            <Tabs>
                                <telerik:RadTab Text="Filter" Value="1" Font-Bold="false" Selected="true" PageViewID="RadPageView1"
                                    Width="80" Style="text-align: center;" />
                                <telerik:RadTab Text="Preview" Value="2" Font-Bold="false" PageViewID="RadPageView2"
                                    Selected="false" Enabled="true" />
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server" Height="100%">
                            <telerik:RadPageView ID="RadPageView1" runat="server" Selected="true" Height="100%">
                                <div style="display: flex; flex-direction: row; height: 100%">
                                    <div style="display: flex; flex-direction: column; width: 327px">
                                        <div style="display: flex; flex-direction: row; width: 100%">
                                            <div style="display: flex; flex-direction: column; border: 1px solid #c2d2e2; width: 100%; margin: 5px;">
                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Operating hospital</span>
                                                </div>
                                                <div id="Div1" runat="server" class="content" style="padding: 15px;">
                                                    <telerik:RadComboBox CheckBoxes="true" EnableCheckAllItemsCheckBox="true" CheckedItemsTexts="DisplayAllInInput"
                                                        ID="OperatingHospitalsRadComboBox" OnItemDataBound="OperatingHospitalsRadComboBox_ItemDataBound"
                                                        runat="server" Width="287px" AutoPostBack="true" />
                                                </div>
                                            </div>
                                        </div>
                                        <div style="display: flex; flex-direction: row; width: 100%">
                                            <div style="display: flex; flex-direction: column; border: 1px solid #c2d2e2; width: 100%; margin: 5px;">
                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Endoscopists</span>
                                                </div>
                                                <div id="Div2" runat="server" class="content" style="padding: 15px; padding-bottom: 21px;">
                                                    <telerik:RadListBox ID="RadListBox1" runat="server" Width="287px" Height="210px"
                                                        Skin="Silk"
                                                        CheckBoxes="true" ShowCheckAll="true"
                                                        SelectionMode="Multiple" DataSourceID="SqlDSAllConsultants" DataKeyField="UserID"
                                                        DataTextField="Consultant"
                                                        DataValueField="UserID">
                                                    </telerik:RadListBox>
                                                    <telerik:RadTextBox runat="server" ID="ISMFilter" CssClass="consultant-search" Width="160px" Visible="false"
                                                        EmptyMessage="Consultant name" Skin="Windows7">
                                                    </telerik:RadTextBox>
                                                    <asp:ObjectDataSource ID="SqlDSAllConsultants" runat="server" SelectMethod="GetConsultantsListBox1"
                                                        TypeName="UnisoftERS.Reporting">
                                                        <SelectParameters>
                                                             <asp:Parameter DefaultValue="All" Name="consultantTypeName" DbType="String"  />
                                                            <asp:ControlParameter Name="searchPhrase" DbType="String" ControlID="ISMFilter" ConvertEmptyStringToNull="true" />
                                                            <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                            <asp:SessionParameter DefaultValue="0" Name="operatingHospitalsIds" SessionField="OperatingHospitalIdsForTrust" Type="String" />
                                                            <asp:Parameter Name="HideSuppressed" DbType="Boolean" DefaultValue="false" />
                                                        </SelectParameters>
                                                    </asp:ObjectDataSource>
                                                    <asp:ObjectDataSource ID="SqlDSSelectedConsultants" runat="server" SelectMethod="GetConsultantsListBox2"
                                                        TypeName="UnisoftERS.Reporting">
                                                        <SelectParameters>
                                                            <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                        </SelectParameters>
                                                    </asp:ObjectDataSource>


                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div style="display: flex; flex-direction: column; width: 650px;">
                                        <div style="display: flex; flex-direction: row; width: 100%">
                                            <div style="display: flex; flex-direction: column; border: 1px solid #c2d2e2; width: 100%; margin: 5px;">

                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Dates</span>
                                                </div>
                                                <div class="content" style="padding: 7px;">
                                                    From:&nbsp;
                                                    <telerik:RadDatePicker ID="RDPFrom" runat="server" Width="150px" Skin="Windows7" RenderMode="classic" />
                                                    &nbsp;To: &nbsp;
                                                    <telerik:RadDatePicker ID="RDPTo" runat="server" Width="150px" Skin="Windows7" />
                                                    <br />
                                                    <asp:HiddenField ID="SUID" runat="server" />
                                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidatorFromDate" ControlToValidate="RDPFrom"
                                                        ErrorMessage="Enter a date!" SetFocusOnError="True" ValidationGroup="FilterGroup"
                                                        ForeColor="Red"></asp:RequiredFieldValidator>
                                                    <asp:RequiredFieldValidator runat="server" ID="RequiredfieldvalidatorToDate" ControlToValidate="RDPTo"
                                                        ErrorMessage="Enter a date!" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                                    <asp:CompareValidator ID="dateCompareValidator" runat="server" ControlToValidate="RDPTo"
                                                        ControlToCompare="RDPFrom" Operator="GreaterThan" ValidationGroup="FilterGroup"
                                                        Type="Date" ErrorMessage="End date must be after the start date." SetFocusOnError="True"
                                                        ForeColor="Red"></asp:CompareValidator>
                                                </div>
                                            </div>
                                        </div>
                                        <div style="display: flex; flex-direction: row; width: 100%">
                                            <div style="display: flex; flex-direction: column; border: 1px solid #c2d2e2; width: 100%; margin: 5px;">
                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Order</span>
                                                </div>
                                                <div class="content" style="padding: 10px;">
                                                    <asp:RadioButtonList ID="DateOrderRadioButton" runat="server" AutoPostBack="false"
                                                        CssClass="" RepeatDirection="Horizontal">
                                                        <asp:ListItem Value="DESC">Date descending (most recent to oldest)</asp:ListItem>
                                                        <asp:ListItem Selected="True" Value="ASC">Date ascending (oldest to most recent)</asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </div>

                                            </div>
                                        </div>

                                        <div style="display: flex; flex-direction: row; width: 100%">
                                            <div style="display: flex; flex-direction: column; border: 1px solid #c2d2e2; width: 100%; margin: 5px;">
                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Status</span>
                                                </div>
                                                <div class="content" style="padding: 10px;">

                                                    <asp:RadioButtonList ID="ProcessedStatusRadioButton" runat="server" AutoPostBack="false"
                                                        CssClass="grsrep" RepeatDirection="Horizontal" RepeatColumns="5" AppendDataBoundItems="true">
                                                        <asp:ListItem Selected="True" Value="-1">All</asp:ListItem>
                                                        <asp:ListItem Value="1">Successful</asp:ListItem>
                                                        <asp:ListItem Value="0">Failed</asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div style="display: flex; flex-direction: row">
                                    <div style="display: flex; flex-direction: column; border: 1px solid #c2d2e2; margin: 5px; width: 965px">
                                    </div>
                                </div>
                                <div style="margin-top: 10px;">
                                    <telerik:RadButton ID="RadButtonFilter" runat="server" Text="Apply filter" Skin="Silk"
                                        ValidationGroup="FilterGroup" OnClientClicking="ValidatingForm" ButtonType="SkinnedButton"
                                        SkinID="RadSkinManager1" Icon-PrimaryIconUrl="~/Images/icons/filter.png" OnClick="RadButtonFilter_Click">
                                    </telerik:RadButton>
                                </div>
                            </telerik:RadPageView>


                            <telerik:RadPageView ID="RadPageView2" runat="server">

                                <div style="padding-left: 20px; padding-right: 20px; padding-bottom: 50px; height: 550px" class="ConfigureBg">

                                    <telerik:RadGrid ID="SummaryReportRadGrid" runat="server" Skin="Office2010Blue" AutoGenerateColumns="false" OnNeedDataSource="RadGridSummary_NeedDataSource">
                                        <ClientSettings Scrolling-AllowScroll="true" Scrolling-UseStaticHeaders="true"></ClientSettings>
                                        <ExportSettings Excel-Format="Html" ExportOnlyData="true" IgnorePaging="true"></ExportSettings>
                                        <MasterTableView CommandItemDisplay="Top" CommandItemStyle-Font-Bold="true">
                                            <CommandItemSettings ShowExportToExcelButton="true" ExportToExcelText="Export" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                            <Columns>
                                                <telerik:GridBoundColumn HeaderText="Procedure Date" DataField="ProcedureDate" HeaderStyle-Width="125"></telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn HeaderText="Patient Number" DataField="PatientNumber" HeaderStyle-Width="175"></telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn HeaderText="Endoscopist" DataField="Endoscopist"></telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn HeaderText="Result" DataField="Result" HeaderStyle-Width="525"></telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn HeaderText="Processed Date" DataField="ProcessedDate" HeaderStyle-Width="125"></telerik:GridBoundColumn>
                                            </Columns>
                                        </MasterTableView>
                                    </telerik:RadGrid>

                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>
                </asp:Panel>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </div>

    <telerik:RadScriptBlock runat="server">

        <script type="text/javascript" src="../../Scripts/Reports.js"></script>
        <script type="text/javascript">
            function ValidatingForm(sender, args) {
                var validated = Page_ClientValidate('FilterGroup');

                if (!validated) return;
                else {
                    if ($('#BodyContentPlaceHolder_BodyContentPlaceHolder_ConsultantPanel').length === 1) {
                        if ($find('<%=RadListBox1.ClientID%>').get_checkedItems().length == 0) {
                            $find('<%=RadNotification1.ClientID%>').set_text("No consultant(s) selected!");
                            $find('<%=RadNotification1.ClientID%>').show();
                            validated = false;
                            args.set_cancel(true);
                        }
                    } else {
                        validated = true;
                    }
                }
            }
        </script>

    </telerik:RadScriptBlock>

</asp:Content>
