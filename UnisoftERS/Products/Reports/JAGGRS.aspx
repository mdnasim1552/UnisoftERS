<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Reports.Master" CodeBehind="JAGGRS.aspx.vb" Inherits="UnisoftERS.JAGGRS" ValidateRequest="False" %>

<%--<style type="text/css">
            .exportToExcelImage {
                background: url(../../Images/Excel-icon.png);
                background-position: 0 0;
                width: 5px;
                height: 5px;
            }

            .jagDivGrid {
                overflow: auto;
                max-height: 470px;
            }
        </style>--%>
<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <script type="text/javascript" src="../../Scripts/Reports.js"></script>
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Metro" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" ForeColor="Red" Position="Center" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>

    <div id="loaderPreview">
        <%--        <img alt="loading" src="../../Images/loader_seq.gif" style="position: fixed; top: 30%; left: 40%; z-index: 5000; width: 400px; height:300px; text-align: center; background: #fff; border: 1px solid #000;" />--%>
        Loading...
    </div>

    <div id="ContentDiv">
        <table>
            <tr>
                <td>
                    <div class="optionsHeading">Reports</div>
                </td>
                <td></td>
            </tr>

        </table>

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="95%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="650px">
                <asp:Panel ID="NoProceduresPanel" runat="server" Visible="false">
                    <div style="padding: 10px;">
                        <p>No procedures to report on</p>
                    </div>
                </asp:Panel>
                <asp:Panel ID="ReportPanel" runat="server">
                    <div style="margin: 0px 10px; width: 95%;">
                        <div style="margin-top: 10px;"></div>

                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" Skin="MetroTouch" RenderMode="Lightweight" Font-Size="Larger">
                            <Tabs>
                                <telerik:RadTab Text="Filter" Value="1" Font-Bold="false" Selected="true" PageViewID="RadPageView1" Width="80" Style="text-align: center;" />
                                <telerik:RadTab Text="Preview" Value="2" Font-Bold="false" PageViewID="RadPageView2" Selected="false" Enabled="true" />
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server">
                            <telerik:RadPageView ID="RadPageView1" runat="server" Selected="true">
                                <div style="padding-bottom: 10px;" class="ConfigureBg">
                                    <table id="ControlsTable" runat="server" class="optionsBodyText" style="margin-top: 15px; margin-left: 15px;" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:Panel ID="FilterPanel" runat="server">
                                                    <asp:ObjectDataSource ID="SqlDSAllConsultants" runat="server" SelectMethod="GetConsultantsListBox1" TypeName="UnisoftERS.Reporting">
                                                        <SelectParameters>
                                                            <asp:Parameter DefaultValue="list,endoscopist1,endoscopist2," Name="consultantTypeName" DbType="String"  />
                                                            <asp:ControlParameter  Name="searchPhrase" DbType="String" ControlID="ISMFilter" ConvertEmptyStringToNull="true" />
                                                            <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                            <asp:SessionParameter DefaultValue="0" Name="operatingHospitalsIds" SessionField="ReportingOperatingHospitalIds" Type="String" />
                                                            <asp:ControlParameter Name="HideSuppressed" DbType="Boolean" ControlID="cbHideSuppressed" PropertyName="Checked" />
                                                        </SelectParameters>
                                                    </asp:ObjectDataSource>
                                                    <asp:ObjectDataSource ID="SqlDSSelectedConsultants" runat="server" SelectMethod="GetConsultantsListBox2" TypeName="UnisoftERS.Reporting">
                                                        <SelectParameters>
                                                            <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                        </SelectParameters>
                                                    </asp:ObjectDataSource>
                                   <div style="display:flex;flex-direction:row; width:100%">
                                        <div style="display:flex;flex-direction:column;border: 1px solid #c2d2e2; width:100%; margin:5px;">
                                            <div class="filterRepHeader collapsible_header">
                                                <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                <span style="padding-left: 5px;">Operating hospital</span>
                                            </div>
                                            <div id="Div1" runat="server" class="content" style="padding: 15px;">
                                                 <div id="HospitalFilterDiv" runat="server" class="optionsBodyText">
                                                   Operating Hospital(s):&nbsp;<telerik:RadComboBox CheckBoxes="true" EnableCheckAllItemsCheckBox="true" CheckedItemsTexts="DisplayAllInInput" ID="OperatingHospitalsRadComboBox" OnItemDataBound="OperatingHospitalsRadComboBox_ItemDataBound" runat="server" Width="270px" AutoPostBack="true"  OnItemChecked="OperatingHospitalsRadComboBox_OnItemChecked" OnCheckAllCheck="OperatingHospitalsRadComboBox_OnCheckAllChange"/> 
                                               </div>
                                            </div>
                                        </div>
                                    </div>
                                                    <table>
                                                        <tr runat="server" id="ConsultantPanel">
                                                            <td>
                                                                <div style="border: 1px solid #c2d2e2;">
                                                                    <div class="filterRepHeader collapsible_header">
                                                                        <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                                        <span style="padding-left: 5px;">Consultant</span>

                                                                    </div>
                                                                    <div class="content" style="height: 235px;">

                                                                        <table style="padding: 10px;">
          
                                                                            <tr>
                                                                                <td style="width: 400px;" colspan="2">
                                                                                    <table id="FilterConsultant" runat="server" border="0">
                                                                                        <tr>
                                                                                            <td style="width: 160px;">
                                                                                                <asp:Label ID="Label1" runat="server" Text="Type word(s) to filter on: "></asp:Label>
                                                                                            </td>
                                                                                            <td>
                                                                                                <telerik:RadTextBox runat="server" ID="ISMFilter" CssClass="consultant-search" Width="160px" EmptyMessage="Consultant name" Skin="Windows7">
                                                                                                </telerik:RadTextBox>
                                <telerik:RadButton ID="UserSearchButton" runat="server" Text="Search" Skin="Office2007" CssClass="filterBtn" />

                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td colspan="2" style="height: 2px;"></td>
                                                                                        </tr>
                                                                                        <tr style="display:none">

                                                                                            <td>
                                                                                                <asp:Label ID="Label2" runat="server" Text="Consultants type: "></asp:Label>
                                                                                            </td>
                                                                                            <td style="text-align: left;">
                                                                                                <telerik:RadComboBox ID="ComboConsultants" runat="server" Width="160px" AutoPostBack="true" Skin="Metro">
                                                                                                    <Items>
                                                                                                        <telerik:RadComboBoxItem runat="server" Text="All" Value="AllConsultants" />
                                                                                                        <telerik:RadComboBoxItem runat="server" Text="Endoscopist 1" Value="Endoscopist1" />
                                                                                                        <telerik:RadComboBoxItem runat="server" Text="Endoscopist 2" Value="Endoscopist2" />
                                                                                                        <telerik:RadComboBoxItem runat="server" Text="List Consultant" Value="ListConsultant" />
                                                                                                        <telerik:RadComboBoxItem runat="server" Text="Assistants or trainees" Value="Assistant" />
                                                                                                    </Items>
                                                                                                </telerik:RadComboBox>
                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr style="display:none">
                                                                                            <td colspan="2" style="padding-top: 30px; text-align: center; width: 100%; color: #c2d2e2;">------------------------------------------</td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td colspan="2" style="height: 40px; padding-top: 10px;">
                                                                                                
                                                                                                    
                                                                                                    <div>
                                                                                                        <asp:CheckBox ID="cbHideSuppressed" runat="server" Text="Hide suppressed endoscopists"  AutoPostBack="true" Skin="Windows7" CssClass="mutuallyexclusive" Style="margin-right: 20px;" OnCheckedChanged="cbHideSuppressed_Click" /><br />
                                                                                                        <asp:CheckBox ID="cbRandomize" runat="server" Text="Randomize and anonymise endoscopists position in report" Skin="Windows7" CssClass="mutuallyexclusive" Visible="false" /><br />
                                                                                                    </div>
                                                                                                
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </td>

                                                                                <td style="padding-left: 25px; vertical-align: top;">
                                                                                    <div>
                                                                                        <telerik:RadAjaxPanel ID="RadAjaxPanel2" runat="server" Height="150px">
                                                                                            <table style="border: 1px solid #c2d2e2; background-color: #ececff;">
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <telerik:RadListBox ID="RadListBox1" runat="server" Width="287px" Height="200px" Skin="Metro"
                                                                                                            CheckBoxes="true" ShowCheckAll="true"
                                                                                                            SelectionMode="Multiple" DataSourceID="SqlDSAllConsultants" DataKeyField="UserID" DataTextField="Consultant"
                                                                                                            DataValueField="UserID">
                                                                                                        </telerik:RadListBox>
                                                                                                    </td>
                                                                                                    <%--         <td>
                                                                                                            <telerik:RadListBox ID="RadListBox2" runat="server" Width="287px" Height="150px" Skin="Office2010Blue"
                                                                                                                SelectionMode="Multiple" AutoPostBackOnReorder="False" EnableDragAndDrop="True"
                                                                                                                DataKeyField="ReportID" DataTextField="Consultant" DataValueField="ReportID" DataSourceID="SqlDSSelectedConsultants">
                                                                                                            </telerik:RadListBox>
                                                                                                        </td>--%>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </telerik:RadAjaxPanel>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>

                                                        <tr>
                                                            <td></td>
                                                        </tr>

                                                        <tr>
                                                            <td style="padding-top: 5px;">
                                                                <div style="border: 1px solid #c2d2e2;">
                                                                    <div class="filterRepHeader collapsible_header">
                                                                        <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                                        <span style="padding-left: 5px;">Dates</span>

                                                                    </div>
                                                                    <div class="content" style="padding-left: 10px;">
                                                                        <table runat="server" border="0" style="margin-top: 5px;">
                                                                            <tr>
                                                                                <td style="text-align: right">From: 
                                                                                </td>
                                                                                <td>
                                                                                    <telerik:RadDatePicker ID="RDPFrom" runat="server" Width="150px" Skin="Windows7" RenderMode="classic" />
                                                                                </td>
                                                                                <td style="text-align: right;">To:
                                                                                </td>
                                                                                <td>
                                                                                    <telerik:RadDatePicker ID="RDPTo" runat="server" Width="150px" Skin="Windows7" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                        <asp:HiddenField ID="SUID" runat="server" />
                                                                        <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidatorFromDate" ControlToValidate="RDPFrom" ErrorMessage="Enter a date!" SetFocusOnError="True" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                                                        <asp:RequiredFieldValidator runat="server" ID="RequiredfieldvalidatorToDate" ControlToValidate="RDPTo" ErrorMessage="Enter a date!" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                                                        <asp:CompareValidator ID="dateCompareValidator" runat="server" ControlToValidate="RDPTo" ControlToCompare="RDPFrom" Operator="GreaterThan" ValidationGroup="FilterGroup" Type="Date" ErrorMessage="The second date must be after the first one." SetFocusOnError="True" ForeColor="Red"></asp:CompareValidator>
                                                                        <%--</fieldset>--%>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-top: 10px;">
                                                                <div style="border: 1px solid #c2d2e2;">
                                                                    <div class="filterRepHeader collapsible_header">
                                                                        <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                                        <span style="padding-left: 5px;">Summary reports</span>

                                                                    </div>
                                                                    <div class="content" style="padding-left: 10px;">
                                                                        <table runat="server" cellspacing="1" cellpadding="1" border="0">
                                                                            <tr>
                                                                                <td>
                                                                                    <div id="EndoList">
                                                                                        <asp:CheckBoxList ID="cbReports" runat="server" RepeatColumns="4" Skin="Windows7" CssClass="mutuallyexclusive">
                                                                                            <asp:ListItem Value="OGD">OGD</asp:ListItem>
                                                                                            <asp:ListItem Value="PEGPEJ">PEG/PEJ</asp:ListItem>
                                                                                            <asp:ListItem Value="ERCP">ERCP</asp:ListItem>
                                                                                            <asp:ListItem Value="Sigmoidoscopy">Sigmoidoscopy</asp:ListItem>
                                                                                            <asp:ListItem Value="Colonoscopy">Colonoscopy</asp:ListItem>
                                                                                            <asp:ListItem Value="EUS">EUS</asp:ListItem>
                                                                                        </asp:CheckBoxList>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <div style="margin-top: 10px;">
                                                                    <telerik:RadButton ID="RadButtonFilter" runat="server" Text="Apply filter" Skin="Silk" ValidationGroup="FilterGroup" OnClientClicking="ValidatingForm" ButtonType="SkinnedButton" SkinID="RadSkinManager1" Icon-PrimaryIconUrl="~/Images/icons/filter.png"></telerik:RadButton>
                                                                      <asp:Button ID="ButtonReset" runat="server" Text="Reset" CellSpacing="0" CellPadding="0" RepeatLayout="Table" RepeatDirection="Vertical" RepeatColumns="1"  OnClientClick="ResetPage()" OnClick="PageReset" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </asp:Panel>
                                            </td>
                                            <td >
                                                <asp:Panel ID="Panel1" runat="server">
                                                     <table>
                                                        <tr runat="server" id="Tr1" >
                                                            <td>
                                                                <div style="border: 1px solid #c2d2e2;">
                                                                    <div class="filterRepHeader">
                                                                        <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                                        <span style="padding-left: 5px;">Other Reports</span>

                                                                    </div>
                                                                    <div class="content" style="padding-left: 10px;height: 535px; width: 500px; overflow-y:auto">
                                                                            <div style="padding: 10px;">
                                                                                <asp:CheckBoxList ID="OtherAudits" runat="server" CellSpacing="0" CellPadding="0"
                                                                                    RepeatLayout="Table" RepeatDirection="Vertical" RepeatColumns="1" />
                                                                            </div>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>

                                                </asp:Panel>
                                            </td>

                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView2" runat="server">

                                <div style="padding: 20px; max-height: 510px;" class="ConfigureBg">
                                    <%--<table id="Table1" runat="server" class="optionsBodyText" style="margin:15px 10px 10px 15px;" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="width:100%;">
                                    <div id="ButtonExport" style="margin-bottom: 10px;visibility:hidden">
                                        <telerik:RadButton ID="RadButtonExportGrids" runat="server" Text="Export Grids to Excel" Enabled="True" Skin="Silk" Style="height: 30px;" Font-Bold="true" Visible="false">
                                        </telerik:RadButton>
                                        <a runat="server" id="downloadFile" visible="false">Download</a>
                                    </div>--%>
                                    <telerik:RadTabStrip ID="RadTabStrip2" runat="server" MultiPageID="RadMultiPage2" SelectedIndex="0" Skin="Office2010Silver" RenderMode="Lightweight">
                                        <Tabs>
                                            <telerik:RadTab runat="server" Text="Summary procedure count" Selected="True">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="Gastroscopy outcomes">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="PEG outcomes">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="ERCP outcomes">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="Colonoscopy outcomes">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="Flexible sigmoidoscopy outcomes">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="Bowel preparation">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="EUS outcomes">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="Endoscopists">
                                            </telerik:RadTab>
                                        </Tabs>
                                    </telerik:RadTabStrip>
                                    <telerik:RadMultiPage ID="RadMultiPage2" runat="server" SelectedIndex="0">
                                        <telerik:RadPageView ID="RadPageNumberOfProceduresPerformed" runat="server">
                                            <div class="jagDivGrid">
                                                <asp:ObjectDataSource ID="DSNumberOfProceduresPerformed" runat="server" SelectMethod="GetTotalProceduresPerformedQry" TypeName="UnisoftERS.Reports">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridNumberOfProceduresPerformed" runat="server" Skin="Office2010Blue" AutoGenerateColumns="False" GroupPanelPosition="Top" PagerStyle-AlwaysVisible="true" ExportSettings-Excel-Format="XLSX" ExportSettings-ExportOnlyData="true">
                                                    <GroupingSettings />
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                                        <Selecting EnableDragToSelectRows="True" CellSelectionMode="SingleCell"></Selecting>
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="Endoscopist1" ClientDataKeyNames="AnonimizedID" CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                                                        <CommandItemSettings ExportToExcelText="Export" ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="AnonimizedID" Display="false" DataType="System.String" UniqueName="AnonimizedID">
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.Int32" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist name" ReadOnly="True" SortExpression="Endoscopist1" UniqueName="Endoscopist1">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" FilterControlAltText="Filter IndependentDirectlySupervisedTraineeDistantSupervisionTrainee column" HeaderText="Independent Directly Supervised/Trainee Distant Supervision Trainee" ReadOnly="True" SortExpression="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee" UniqueName="IndependentDirectlySupervisedTraineeDistantSupervisionTrainee">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridHyperLinkColumn DataTextField="TotalOGD" DataType="System.Int32" FilterControlAltText="Filter TotalOGD column" HeaderText="Total OGD" SortExpression="TotalOGD" UniqueName="TotalOGD" ColumnGroupName="UnSelectable" DataNavigateUrlFormatString="javascript:OpenDetails('OGD', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle BorderStyle="Solid" HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>
                                                            <telerik:GridHyperLinkColumn DataTextField="TotalEUS" DataType="System.Int32" FilterControlAltText="Filter TotalEUS column" HeaderText="Total EUS" SortExpression="TotalEUS" UniqueName="TotalEUS" ColumnGroupName="UnSelectable" DataNavigateUrlFormatString="javascript:OpenDetails('EUS', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle BorderStyle="Solid" HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>
                                                            <telerik:GridHyperLinkColumn DataTextField="TotalERCP" DataType="System.Int32" FilterControlAltText="Filter TotalERCP column" HeaderText="Total ERCP" SortExpression="TotalERCP" UniqueName="TotalERCP" ColumnGroupName="UnSelectable" DataNavigateUrlFormatString="javascript:OpenDetails('ERC', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle BorderStyle="Solid" HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>
                                                            <telerik:GridHyperLinkColumn DataTextField="TotalSIG" DataType="System.Int32" FilterControlAltText="Filter TotalSIG column" HeaderText="Total Flexible Sigmoidoscopy" SortExpression="TotalSIG" UniqueName="TotalSIG" ColumnGroupName="UnSelectable" DataNavigateUrlFormatString="javascript:OpenDetails('SIG', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle BorderStyle="Solid" HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>
                                                            <telerik:GridHyperLinkColumn DataTextField="TotalCOL" DataType="System.Int32" FilterControlAltText="Filter TotalCOL column" HeaderText="Total Colonoscopy" SortExpression="TotalCOL" UniqueName="TotalCOL" ColumnGroupName="UnSelectable" DataNavigateUrlFormatString="javascript:OpenDetails('COL', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle BorderStyle="Solid" HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>
                                                            <telerik:GridBoundColumn DataField="TotalProctoscopy" DataType="System.Int32" FilterControlAltText="Filter TotalProctoscopy column" HeaderText="Total Proctoscopy" ReadOnly="True" SortExpression="TotalProctoscopy" UniqueName="TotalProctoscopy" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle BorderStyle="Solid" HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="TotalEntAntegrade" DataType="System.Int32" FilterControlAltText="Filter TotalEntAntegrade column" HeaderText="Total Enteroscopy Antigrade" ReadOnly="True" SortExpression="TotalEntAntegrade" UniqueName="TotalEntAntegrade" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle BorderStyle="Solid" HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="TotalEntRetrograde" DataType="System.Int32" FilterControlAltText="Filter TotalEntRetrograde column" HeaderText="Total Enteroscopy Retrograde" ReadOnly="True" SortExpression="TotalEntRetrograde" UniqueName="TotalEntRetrograde" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle BorderStyle="Solid" HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageGastroscopy" runat="server">
                                            <div class="jagDivGrid">
                                                <%--<h1>JAG/GRS Report: Gastroscopy results</h1>--%>
                                                <!--Ojo-->
                                                <telerik:RadContextMenu ID="RadContextMenuOGD" runat="server" OnClientItemClicked="getContextMenuOGD">
                                                    <Targets>
                                                        <telerik:ContextMenuControlTarget ControlID="RadGridGastroscopy" />
                                                        <telerik:ContextMenuElementTarget ElementID="" />
                                                    </Targets>
                                                    <Items>
                                                    </Items>
                                                </telerik:RadContextMenu>
                                                <asp:ObjectDataSource ID="DSGastroscopy" runat="server" SelectMethod="GetOGDQry" TypeName="UnisoftERS.Reports">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridGastroscopy" runat="server" Skin="Office2010Blue" AutoGenerateColumns="False" GroupPanelPosition="Top" PagerStyle-AlwaysVisible="true" ExportSettings-Excel-Format="XLSX" ExportSettings-ExportOnlyData="true">
                                                    <GroupingSettings />
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                                        <Selecting EnableDragToSelectRows="True" CellSelectionMode="SingleCell"></Selecting>
                                                        <%--<ClientEvents OnCellSelected="SelectCellOGD"></ClientEvents>--%>
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="Endoscopist1" ClientDataKeyNames="AnonimizedID" CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                                                        <CommandItemSettings ExportToExcelText="Export" ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="AnonimizedID" Display="false" DataType="System.String" UniqueName="AnonimizedID">
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.Int32" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist name" ReadOnly="True" SortExpression="Endoscopist1" UniqueName="Endoscopist1">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridHyperLinkColumn DataTextField="NumberOfProcedures" DataType="System.Int32" FilterControlAltText="Filter NumberOfProcedures column" HeaderText="Total gastroscopies" SortExpression="NumberOfProcedures" 
                                                                UniqueName="NumberOfProcedures" ColumnGroupName="Selectable" DataNavigateUrlFormatString="javascript:OpenDetails('OGD', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle BorderStyle="Solid" HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>
                                                            <telerik:GridBoundColumn DataField="SuccessOfIntubationP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter SuccessOfIntubationP column" HeaderText="Success of intubation" 
                                                                ReadOnly="True" SortExpression="SuccessOfIntubationP" UniqueName="SuccessOfIntubationP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="CompletenessOfProcedureP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter D2 rate column" HeaderText="D2 intubation rate" 
                                                                ReadOnly="True" SortExpression="CompletenessOfProcedureP" UniqueName="CompletenessOfProcedureP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="JManoeuvreRate" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter J manoeuvre rate column" HeaderText="J manoeuvre rate" 
                                                                ReadOnly="True" SortExpression="JManoeuvreRate" UniqueName="JManoeuvreRate" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ComfortLevelModerateSevereDiscomfort" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter sedation column" HeaderText="Endoscopist comfort rate % moderate or severe discomfort" 
                                                                ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfort" UniqueName="ComfortLevelModerateSevereDiscomfort" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ComfortLevelModerateSevereDiscomfortNurse" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter sedation column" HeaderText="Nurse comfort rate % moderate or severe discomfort" 
                                                                ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfortNurse" UniqueName="ComfortLevelModerateSevereDiscomfortNurse" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianSedationRateLT70Years_Midazolam" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Midazolam column" HeaderText="Median dose (Age <70) Midazolam" 
                                                                ReadOnly="True" SortExpression="MedianSedationRateLT70Years_Midazolam" UniqueName="MedianSedationRateLT70Years_Midazolam" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateLT70Years_Pethidine" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Pethidine column" HeaderText="Median dose (Age <70) Pethidine" 
                                                                ReadOnly="True" SortExpression="MedianAnalgesiaRateLT70Years_Pethidine" UniqueName="MedianAnalgesiaRateLT70Years_Pethidine" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateLT70Years_Fentanyl" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Fentanyl column" HeaderText="Median dose (Age <70) Fentanyl" 
                                                                ReadOnly="True" SortExpression="MedianAnalgesiaRateLT70Years_Fentanyl" UniqueName="MedianAnalgesiaRateLT70Years_Fentanyl" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianSedationRateGE70Years_Midazolam" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Midazolam column" HeaderText="Median dose (Age >70) Midazolam" 
                                                                ReadOnly="True" SortExpression="MedianSedationRateGE70Years_Midazolam" UniqueName="MedianSedationRateGE70Years_Midazolam" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateGE70Years_Pethidine" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Pethidine column" HeaderText="Median dose (Age >70) Pethidine" 
                                                                ReadOnly="True" SortExpression="MedianAnalgesiaRateGE70Years_Pethidine" UniqueName="MedianAnalgesiaRateGE70Years_Pethidine" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateGE70Years_Fentanyl" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Fentanyl column" HeaderText="Median dose (Age >70) Fentanyl" 
                                                                ReadOnly="True" SortExpression="MedianAnalgesiaRateGE70Years_Fentanyl" UniqueName="MedianAnalgesiaRateGE70Years_Fentanyl" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="GTRecommededDose" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Greater than recommended dose of sedation column" HeaderText="Greater than recommended dose of sedation" 
                                                                ReadOnly="True" SortExpression="GTRecommededDose" UniqueName="GTRecommededDose" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoSedationP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Unsedated procedures in % column" HeaderText="Unsedated procedures in %" 
                                                                ReadOnly="True" SortExpression="NoSedationP" UniqueName="NoSedationP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPagePEGPEJ" runat="server">
                                            <div class="jagDivGrid">
                                                <%--<h1>JAG/GRS Report: PEG/PEJ results</h1>--%>
                                                <telerik:RadContextMenu ID="RadContextMenuPEG" runat="server" OnClientItemClicked="getContextMenuPEG">
                                                    <Targets>
                                                        <telerik:ContextMenuControlTarget ControlID="RadGridPEGPEJ" />
                                                        <telerik:ContextMenuElementTarget ElementID="" />
                                                    </Targets>
                                                    <Items>
                                                    </Items>
                                                </telerik:RadContextMenu>
                                                <asp:ObjectDataSource ID="DSPEGPEJ" runat="server" SelectMethod="GetPEGQry" TypeName="UnisoftERS.Reports">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridPEGPEJ" runat="server" Skin="Office2010Blue" GroupPanelPosition="Top" AutoGenerateColumns="False" PagerStyle-AlwaysVisible="true"  ExportSettings-Excel-Format="XLSX" ExportSettings-ExportOnlyData="true">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                                        <Selecting CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                                        <%--<ClientEvents OnCellSelected="SelectCellPEG"></ClientEvents>--%>
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="Endoscopist1" ClientDataKeyNames="AnonimizedID" CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                                                        <CommandItemSettings ExportToExcelText="Export" ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="AnonimizedID" Display="false" DataType="System.String" UniqueName="AnonimizedID">
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.String" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist name" ReadOnly="True" SortExpression="Endoscopist1" 
                                                                UniqueName="Endoscopist1">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridHyperLinkColumn DataTextField="NumberOfProcedures" DataType="System.Int32" FilterControlAltText="Filter NumberOfProcedures column" HeaderText="Total PEG procedures" 
                                                                SortExpression="NumberOfProcedures" 
                                                                UniqueName="NumberOfProcedures" ColumnGroupName="Selectable" DataNavigateUrlFormatString="javascript:OpenDetails('PEG', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>

                                                            <telerik:GridBoundColumn DataField="SatisfactoryPlacementOfPEGP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Satisfactory placement of PEG column" HeaderText="Satisfactory placement of PEG %" 
                                                                ReadOnly="True" SortExpression="SatisfactoryPlacementOfPEGP" UniqueName="SatisfactoryPlacementOfPEGP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PostProcedureInfectionRequiringAntibioticsP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Post procedure infection requiring antibiotics column" 
                                                                HeaderText="Post procedure infection requiring antibiotics %" ReadOnly="True" SortExpression="SatisfactoryPlacementOfPostProcedureInfectionRequiringAntibioticsPPEGP" UniqueName="PostProcedureInfectionRequiringAntibioticsP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PostProcedurePeritonitisP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Post procedure peritonitis column" HeaderText="Post procedure peritonitis %" 
                                                                ReadOnly="True" SortExpression="PostProcedurePeritonitisP" UniqueName="PostProcedurePeritonitisP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="BleedingRequiringTransfusionP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Bleeding requiring transfusion column" 
                                                                HeaderText="Bleeding requiring transfusion %" ReadOnly="True" SortExpression="BleedingRequiringTransfusionP" UniqueName="BleedingRequiringTransfusionP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageERCP" runat="server">
                                            <div class="jagDivGrid">
                                                <%--<h1>JAG/GRS Report: ERCP results</h1>--%>
                                                <telerik:RadContextMenu ID="RadContextMenuERC" runat="server" OnClientItemClicked="getContextMenuERC">
                                                    <Targets>
                                                        <telerik:ContextMenuControlTarget ControlID="RadGridERCP" />
                                                        <telerik:ContextMenuElementTarget ElementID="" />
                                                    </Targets>
                                                    <Items>
                                                    </Items>
                                                </telerik:RadContextMenu>
                                                <asp:ObjectDataSource ID="DSERCP" runat="server" SelectMethod="GetERCQry" TypeName="UnisoftERS.Reports">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>

                                                <telerik:RadGrid ID="RadGridERCP" runat="server" Skin="Office2010Blue" GroupPanelPosition="Top" AutoGenerateColumns="False" CellSpacing="-1" PagerStyle-AlwaysVisible="true" ExportSettings-Excel-Format="XLSX" ExportSettings-ExportOnlyData="true">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                                        <Selecting CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                                        <%--<ClientEvents OnCellSelected="SelectCellERC"></ClientEvents>--%>
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="Endoscopist1" ClientDataKeyNames="AnonimizedID" CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                                                        <CommandItemSettings ExportToExcelText="Export" ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="AnonimizedID" Display="false" DataType="System.String" UniqueName="AnonimizedID">
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.String" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist name" ReadOnly="True" 
                                                                SortExpression="Endoscopist1" UniqueName="Endoscopist1">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridHyperLinkColumn DataTextField="NumberOfProcedures" DataType="System.Int32" FilterControlAltText="Filter NumberOfProcedures column" HeaderText="Total ERCP procedures" 
                                                                SortExpression="NumberOfProcedures" UniqueName="NumberOfProcedures" ColumnGroupName="Selectable" DataNavigateUrlFormatString="javascript:OpenDetails('ERC', '{0}')"
                                                                DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>

                                                            <telerik:GridBoundColumn DataField="CannulationOfIntendedDuctAtFirstERCP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Successful cannulation of clinically relevant duct at 1st ever ERCP column" 
                                                                HeaderText="Successful cannulation of clinically relevant duct at 1st ever ERCP" ReadOnly="True" SortExpression="CannulationOfIntendedDuctAtFirstERCP" 
                                                                UniqueName="CannulationOfIntendedDuctAtFirstERCP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="CommonBileDuctStoneCclearanceAtFirstERCP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter CBD Stone clearance 1st ever ERCP column" 
                                                                HeaderText="CBD Stone clearance 1st ever ERCP" ReadOnly="True" SortExpression="CommonBileDuctStoneCclearanceAtFirstERCP" UniqueName="CommonBileDuctStoneCclearanceAtFirstERCP" 
                                                                ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ExtraHepaticStrictureStentSiting" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter stricture stent placement column"
                                                                HeaderText="Extra-hepatic stricture cytology/histology and stent placement at first ever ERCP" ReadOnly="True" SortExpression="ExtraHepaticStrictureStentSiting" 
                                                                UniqueName="ExtraHepaticStrictureStentSiting"
                                                                ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="MedianSedationRateLT70Years_Midazolam" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Midazolam column" 
                                                                HeaderText="Median dose (Age <70) Midazolam" ReadOnly="True" SortExpression="MedianSedationRateLT70Years_Midazolam" UniqueName="MedianSedationRateLT70Years_Midazolam" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateLT70Years_Pethidine" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Pethidine column" 
                                                                HeaderText="Median dose (Age <70) Pethidine" ReadOnly="True" SortExpression="MedianAnalgesiaRateLT70Years_Pethidine" UniqueName="MedianAnalgesiaRateLT70Years_Pethidine" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateLT70Years_Fentanyl" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Fentanyl column" 
                                                                HeaderText="Median dose (Age <70) Fentanyl" ReadOnly="True" SortExpression="MedianAnalgesiaRateLT70Years_Fentanyl" UniqueName="MedianAnalgesiaRateLT70Years_Fentanyl" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianSedationRateGE70Years_Midazolam" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Midazolam column" 
                                                                HeaderText="Median dose (Age >70) Midazolam" ReadOnly="True" SortExpression="MedianSedationRateGE70Years_Midazolam" UniqueName="MedianSedationRateGE70Years_Midazolam" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateGE70Years_Pethidine" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Pethidine column"
                                                                HeaderText="Median dose (Age >70) Pethidine" ReadOnly="True" SortExpression="MedianAnalgesiaRateGE70Years_Pethidine" UniqueName="MedianAnalgesiaRateGE70Years_Pethidine" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateGE70Years_Fentanyl" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Fentanyl column" 
                                                                HeaderText="Median dose (Age >70) Fentanyl" ReadOnly="True" SortExpression="MedianAnalgesiaRateGE70Years_Fentanyl" UniqueName="MedianAnalgesiaRateGE70Years_Fentanyl" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="GTRecommededDose" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Greater than recommended dose of sedation column"
                                                                HeaderText="Greater than recommended dose of sedation" ReadOnly="True" SortExpression="GTRecommededDose" UniqueName="GTRecommededDose" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoSedationP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Unsedated procedures in % column" 
                                                                HeaderText="Unsedated procedures in %" ReadOnly="True" SortExpression="NoSedationP" UniqueName="NoSedationP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PropofolP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter % of procedures performed with propofol column" 
                                                                HeaderText="% of procedures performed with propofol" ReadOnly="True" SortExpression="PropofolP" UniqueName="PropofolP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ComfortLevelModerateSevereDiscomfort" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter sedation column" 
                                                                HeaderText="Endoscopist comfort rate % moderate or severe discomfort" ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfort" UniqueName="ComfortLevelModerateSevereDiscomfort" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ComfortLevelModerateSevereDiscomfortNurse" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter sedation column" HeaderText="Nurse Comfort rate % moderate or severe discomfort" 
                                                                ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfortNurse" UniqueName="ComfortLevelModerateSevereDiscomfortNurse" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageColonoscopy" runat="server">
                                            <div class="jagDivGrid">
                                                <%--<h1>JAG/GRS Report: Colonoscopy results</h1>--%>
                                                <telerik:RadContextMenu ID="RadContextMenuCOL" runat="server" OnClientItemClicked="getContextMenuCOL">
                                                    <Targets>
                                                        <telerik:ContextMenuControlTarget ControlID="RadGridColonoscopy" />
                                                        <telerik:ContextMenuElementTarget ElementID="" />
                                                    </Targets>
                                                    <Items>
                                                    </Items>
                                                </telerik:RadContextMenu>
                                                <asp:ObjectDataSource ID="DSColonoscopy" runat="server" SelectMethod="GetCOLQry" TypeName="UnisoftERS.Reports">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridColonoscopy" runat="server" Skin="Office2010Blue" AutoGenerateColumns="False" GroupPanelPosition="Top" PagerStyle-AlwaysVisible="true" ExportSettings-Excel-Format="XLSX" ExportSettings-ExportOnlyData="true">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                                        <Selecting CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                                        <%--<ClientEvents OnCellSelected="SelectCellCOL"></ClientEvents>--%>
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="Endoscopist1" ClientDataKeyNames="AnonimizedID" CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                                                        <CommandItemSettings ExportToExcelText="Export" ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="AnonimizedID" Display="false" DataType="System.String" UniqueName="AnonimizedID">
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.Int32" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist name" ReadOnly="True" SortExpression="Endoscopist1" 
                                                                UniqueName="Endoscopist1">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridHyperLinkColumn DataTextField="NumberOfProcedures" DataType="System.Int32" FilterControlAltText="Filter NumberOfProcedures column" HeaderText="Total colonoscopies" 
                                                                SortExpression="NumberOfProcedures" UniqueName="NumberOfProcedures" ColumnGroupName="Selectable" DataNavigateUrlFormatString="javascript:OpenDetails('COL', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>
                                                            <telerik:GridBoundColumn DataField="DigiRectalExaminationP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Digital rectal examination column" 
                                                                HeaderText="Digital rectal examination" ReadOnly="True" SortExpression="DigiRectalExaminationP" UniqueName="DigiRectalExaminationP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="UnadjustedCaecalIntubationRate" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Unadjusted caecal intubation rate* column"
                                                                HeaderText="Unadjusted caecal intubation rate" ReadOnly="True" SortExpression="UnadjustedCaecalIntubationRate" UniqueName="UnadjustedCaecalIntubationRate" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="TerminalIlealIntubationRate" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Terminal ileal intubation rate in % column"
                                                                HeaderText="Terminal ileal intubation rate in %" ReadOnly="True" SortExpression="TerminalIlealIntubationRate" UniqueName="TerminalIlealIntubationRate" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PolypDetectionRate" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Polyp detection rate** column" HeaderText="Polyp detection rate**" 
                                                                ReadOnly="True" SortExpression="PolypDetectionRate" UniqueName="PolypDetectionRate" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PolypRetrievalRateP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Polyp retrieval rate column" HeaderText="Polyp retrieval rate"
                                                                ReadOnly="True" SortExpression="PolypRetrievalRateP" UniqueName="PolypRetrievalRateP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MeanWithdrawalTime" DataType="System.Double" DataFormatString="{0:F2}" FilterControlAltText="Filter Withdrawal time column" HeaderText="Withdrawal time" 
                                                                ReadOnly="True" SortExpression="MeanWithdrawalTime" UniqueName="MeanWithdrawalTime" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="RectalRetoversionRateP" DataType="System.Double" DataFormatString="{0:P0}" FilterControlAltText="Filter Rectal retroversion rate column" 
                                                                HeaderText="Rectal retroversion rate" ReadOnly="True" SortExpression="RectalRetoversionRateP" UniqueName="RectalRetoversionRateP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ComfortLevelModerateSevereDiscomfort" DataType="System.Double" DataFormatString="{0:P0}" FilterControlAltText="Filter Comfort score*** column" 
                                                                HeaderText="Endoscopist comfort rate % moderate or severe discomfort" ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfort" UniqueName="ComfortLevelModerateSevereDiscomfort" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ComfortLevelModerateSevereDiscomfortNurse" DataType="System.Double" DataFormatString="{0:P0}" FilterControlAltText="Filter Comfort score*** column" 
                                                                HeaderText="Nurse comfort rate % moderate or severe discomfort" ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfortNurse" UniqueName="ComfortLevelModerateSevereDiscomfortNurse" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianSedationRateLT70Years_Midazolam" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Midazolam column" 
                                                                HeaderText="Median dose (Age <70) Midazolam" ReadOnly="True" SortExpression="MedianSedationRateLT70Years_Midazolam" UniqueName="MedianSedationRateLT70Years_Midazolam" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateLT70Years_Pethidine" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Pethidine column" 
                                                                HeaderText="Median dose (Age <70) Pethidine" ReadOnly="True" SortExpression="MedianAnalgesiaRateLT70Years_Pethidine" UniqueName="MedianAnalgesiaRateLT70Years_Pethidine" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateLT70Years_Fentanyl" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Fentanyl column" 
                                                                HeaderText="Median dose (Age <70) Fentanyl" ReadOnly="True" SortExpression="MedianAnalgesiaRateLT70Years_Fentanyl" UniqueName="MedianAnalgesiaRateLT70Years_Fentanyl" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianSedationRateGE70Years_Midazolam" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Midazolam column"
                                                                HeaderText="Median dose (Age >70) Midazolam" ReadOnly="True" SortExpression="MedianSedationRateGE70Years_Midazolam" UniqueName="MedianSedationRateGE70Years_Midazolam" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateGE70Years_Pethidine" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Pethidine column"
                                                                HeaderText="Median dose (Age >70) Pethidine" ReadOnly="True" SortExpression="MedianAnalgesiaRateGE70Years_Pethidine" UniqueName="MedianAnalgesiaRateGE70Years_Pethidine" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateGE70Years_Fentanyl" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Fentanyl column" 
                                                                HeaderText="Median dose (Age >70) Fentanyl" ReadOnly="True" SortExpression="MedianAnalgesiaRateGE70Years_Fentanyl" UniqueName="MedianAnalgesiaRateGE70Years_Fentanyl" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="GTRecommededDose" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Greater than recommended dose of sedation column" 
                                                                HeaderText="Greater than recommended dose of sedation" ReadOnly="True" SortExpression="GTRecommededDose" UniqueName="GTRecommededDose" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoSedationP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Unsedated procedures in % column" HeaderText="Unsedated procedures in %" 
                                                                ReadOnly="True" SortExpression="NoSedationP" UniqueName="NoSedationP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="DiagnosticRectalBiopsiesForUnexplainedDiarrohea" 
                                                                FilterControlAltText="Filter Diagnostic rectal biopsies for diarrhoea column" HeaderText="Diagnostic R & L colon biopsies for diarrhoea" ReadOnly="True"
                                                                SortExpression="DiagnosticRectalBiopsiesForUnexplainedDiarrohea" UniqueName="DiagnosticRectalBiopsiesForUnexplainedDiarrohea" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="TattooingOfAllLesionsP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter tattooed lesions % column" 
                                                                HeaderText="Tattooing all lesions ≥20mm and/or suspicious of cancer outside of rectum and caecum" ReadOnly="True" SortExpression="TattooingOfAllLesionsP" UniqueName="TattooingOfAllLesionsP" 
                                                                ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageSigmoidoscopy" runat="server">
                                            <div class="jagDivGrid">
                                                <%--<h1>JAG/GRS Report: Sigmoidoscopy results</h1>--%>
                                                <telerik:RadContextMenu ID="RadContextMenuSIG" runat="server" OnClientItemClicked="getContextMenuSIG">
                                                    <Targets>
                                                        <telerik:ContextMenuControlTarget ControlID="RadGridSigmoidoscopy" />
                                                        <telerik:ContextMenuElementTarget ElementID="" />
                                                    </Targets>
                                                    <Items>
                                                    </Items>
                                                </telerik:RadContextMenu>
                                                <asp:ObjectDataSource ID="DSSigmoidoscopy" runat="server" SelectMethod="GetSIGQry" TypeName="UnisoftERS.Reports">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>

                                                <telerik:RadGrid ID="RadGridSigmoidoscopy" runat="server" Skin="Office2010Blue" GroupPanelPosition="Top" AutoGenerateColumns="False" CellSpacing="-1" PagerStyle-AlwaysVisible="true" ExportSettings-Excel-Format="XLSX" ExportSettings-ExportOnlyData="true">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                                        <Selecting CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                                        <%--<ClientEvents OnCellSelected="SelectCellSIG"></ClientEvents>--%>
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="Endoscopist1" ClientDataKeyNames="AnonimizedID" CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                                                        <CommandItemSettings ExportToExcelText="Export" ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="AnonimizedID" Display="false" DataType="System.String" UniqueName="AnonimizedID">
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.Int32" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist name" ReadOnly="True" SortExpression="Endoscopist1" 
                                                                UniqueName="Endoscopist1">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridHyperLinkColumn DataTextField="NumberOfProcedures" DataType="System.Int32" FilterControlAltText="Filter NumberOfProcedures column" HeaderText="Total sigmoidoscopies" 
                                                                SortExpression="NumberOfProcedures" UniqueName="NumberOfProcedures" ColumnGroupName="Selectable" DataNavigateUrlFormatString="javascript:OpenDetails('SIG', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>
                                                            <telerik:GridBoundColumn DataField="DigiRectalExaminationP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Digital rectal examination column" 
                                                                HeaderText="Digital rectal examination" ReadOnly="True" SortExpression="DigiRectalExaminationP" UniqueName="DigiRectalExaminationP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="SplenicFlexureIntubationRate" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Extent of procedure – splenic flexure in % column" 
                                                                HeaderText="Extent of procedure – splenic flexure in %" ReadOnly="True" SortExpression="SplenicFlexureIntubationRate" UniqueName="SplenicFlexureIntubationRate" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="DescendingIntubationRate" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Extent of procedure – descending colon in %column" 
                                                                HeaderText="Extent of procedure – descending colon in %" ReadOnly="True" SortExpression="DescendingIntubationRate" UniqueName="DescendingIntubationRate" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PolypDetectionRate" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Polyp detection rate** column" 
                                                                HeaderText="Polyp detection rate**" ReadOnly="True" SortExpression="PolypDetectionRate" UniqueName="PolypDetectionRate" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PolypRetrievalRateP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Polyp retrieval rate column" HeaderText="Polyp retrieval rate" 
                                                                ReadOnly="True" SortExpression="PolypRetrievalRateP" UniqueName="PolypRetrievalRateP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="RectalRetoversionRateP" DataType="System.Double" DataFormatString="{0:P0}" FilterControlAltText="Filter Rectal retroversion rate column" HeaderText="Rectal retroversion rate"
                                                                ReadOnly="True" SortExpression="RectalRetoversionRateP" UniqueName="RectalRetoversionRateP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ComfortLevelModerateSevereDiscomfort" DataType="System.Double" DataFormatString="{0:P0}" FilterControlAltText="Filter Comfort score column" HeaderText="Endoscopist comfort rate % moderate or severe discomfort" 
                                                                ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfort" UniqueName="ComfortLevelModerateSevereDiscomfort" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="ComfortLevelModerateSevereDiscomfortNurse" DataType="System.Double" DataFormatString="{0:P0}" FilterControlAltText="Filter Comfort score column" HeaderText="Nurse comfort rate % moderate or severe discomfort" 
                                                                ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfortNurse" UniqueName="ComfortLevelModerateSevereDiscomfortNurse" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>


                                                            <telerik:GridBoundColumn DataField="MedianSedationRateLT70Years_Midazolam" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Midazolam column"
                                                                HeaderText="Median dose (Age <70) Midazolam" ReadOnly="True" SortExpression="MedianSedationRateLT70Years_Midazolam" UniqueName="MedianSedationRateLT70Years_Midazolam" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateLT70Years_Pethidine" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Pethidine column" 
                                                                HeaderText="Median dose (Age <70) Pethidine" ReadOnly="True" SortExpression="MedianAnalgesiaRateLT70Years_Pethidine" UniqueName="MedianAnalgesiaRateLT70Years_Pethidine" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateLT70Years_Fentanyl" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Fentanyl column" 
                                                                HeaderText="Median dose (Age <70) Fentanyl" ReadOnly="True" SortExpression="MedianAnalgesiaRateLT70Years_Fentanyl" UniqueName="MedianAnalgesiaRateLT70Years_Fentanyl" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianSedationRateGE70Years_Midazolam" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Midazolam column" 
                                                                HeaderText="Median dose (Age >70) Midazolam" ReadOnly="True" SortExpression="MedianSedationRateGE70Years_Midazolam" UniqueName="MedianSedationRateGE70Years_Midazolam" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateGE70Years_Pethidine" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Pethidine column" 
                                                                HeaderText="Median dose (Age >70) Pethidine" ReadOnly="True" SortExpression="MedianAnalgesiaRateGE70Years_Pethidine" UniqueName="MedianAnalgesiaRateGE70Years_Pethidine" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateGE70Years_Fentanyl" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Fentanyl column"
                                                                HeaderText="Median dose (Age >70) Fentanyl" ReadOnly="True" SortExpression="MedianAnalgesiaRateGE70Years_Fentanyl" UniqueName="MedianAnalgesiaRateGE70Years_Fentanyl" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="GTRecommededDose" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Greater than recommended dose of sedation column" 
                                                                HeaderText="Greater than recommended dose of sedation" ReadOnly="True" SortExpression="GTRecommededDose" UniqueName="GTRecommededDose" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoSedationP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Unsedated procedures in % column" HeaderText="Unsedated procedures in %" 
                                                                ReadOnly="True" SortExpression="NoSedationP" UniqueName="NoSedationP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <%--<telerik:GridBoundColumn DataField="DiagnosticRectalBiopsiesForUnexplainedDiarrohea" DataType="System.Decimal" DataFormatString="{0:P0}" 
                                                                FilterControlAltText="Filter Diagnostic rectal biopsies for diarrhoea column" HeaderText="Diagnostic rectal biopsies for diarrhoea" ReadOnly="True"
                                                                SortExpression="DiagnosticRectalBiopsiesForUnexplainedDiarrohea" UniqueName="DiagnosticRectalBiopsiesForUnexplainedDiarrohea" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>--%>

                                                            <telerik:GridBoundColumn DataField="TattooingOfAllLesionsP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter tattooed lesions % column" 
                                                                HeaderText="Tattooing all lesions ≥20mm and/or suspicious of cancer outside of rectum and caecum" ReadOnly="True" SortExpression="TattooingOfAllLesionsP" UniqueName="TattooingOfAllLesionsP" 
                                                                ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageBowel" runat="server">
                                            <div class="jagDivGrid">
                                                <%--<h1>JAG/GRS Report: Bowel preparations</h1>--%>
                                                <telerik:RadContextMenu ID="RadContextMenuBowel" runat="server" OnClientItemClicked="getContextMenuBowel">
                                                    <Targets>
                                                        <telerik:ContextMenuControlTarget ControlID="RadGridBowel" />
                                                        <telerik:ContextMenuElementTarget ElementID="" />
                                                    </Targets>
                                                    <Items>
                                                    </Items>
                                                </telerik:RadContextMenu>
                                                <asp:ObjectDataSource ID="DSBowel" runat="server" SelectMethod="GetBowelQry" TypeName="UnisoftERS.Reports">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridBowel" runat="server" Skin="Office2010Blue" AutoGenerateColumns="False" GroupPanelPosition="Top" PagerStyle-AlwaysVisible="true">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                                        <Selecting CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                                        <%--<ClientEvents OnCellSelected="SelectCellBowel"></ClientEvents>--%>
                                                    </ClientSettings>
                                                    <MasterTableView CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                                                        <CommandItemSettings ExportToExcelText="Export" ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="BowelPreparationType" FilterControlAltText="Filter BowelPreparationType column" HeaderText="Bowel Preparation Type" SortExpression="BowelPreparationType"
                                                                UniqueName="BowelPreparationType">
                                                                <HeaderStyle HorizontalAlign="Center" CssClass="div150" />
                                                                <ItemStyle HorizontalAlign="Center" CssClass="div150" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridHyperLinkColumn DataTextField="Total" DataType="System.Int32" FilterControlAltText="Filter Total column" HeaderText="Total" SortExpression="Total" UniqueName="Total"
                                                                DataNavigateUrlFormatString="javascript:OpenDetails('BOW', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" CssClass="div75" />
                                                                <ItemStyle HorizontalAlign="Center" CssClass="div75" />
                                                            </telerik:GridHyperLinkColumn>
                                                            <telerik:GridBoundColumn DataField="PreparationRecordedAdequateOrAboveP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter PreparationRecordedAdequateOrAboveP column"
                                                                HeaderText="Preparation recorded adequate or above (90%)" ReadOnly="True" SortExpression="PreparationRecordedAdequateOrAboveP" UniqueName="PreparationRecordedAdequateOrAboveP">
                                                                <HeaderStyle HorizontalAlign="Center" CssClass="div75" />
                                                                <ItemStyle HorizontalAlign="Center" CssClass="div75" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="ClinicalLeadReviewAndActionRequired" FilterControlAltText="Filter ClinicalLeadReviewAndActionRequired column"
                                                                HeaderText="Clinical lead review and action required (must be completed)" ReadOnly="True" SortExpression="ClinicalLeadReviewAndActionRequired" UniqueName="ClinicalLeadReviewAndActionRequired">
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageEUS" runat="server">
                                            <div class="jagDivGrid">
                                                <%--<h1>JAG/GRS Report: EUS results</h1>--%>
                                                <telerik:RadContextMenu ID="RadContextMenuEUS" runat="server" OnClientItemClicked="getContextMenuEUS">
                                                    <Targets>
                                                        <telerik:ContextMenuControlTarget ControlID="RadGridEUS" />
                                                        <telerik:ContextMenuElementTarget ElementID="" />
                                                    </Targets>
                                                    <Items>
                                                    </Items>
                                                </telerik:RadContextMenu>
                                                <asp:ObjectDataSource ID="DSEUS" runat="server" SelectMethod="GetEUSQry" TypeName="UnisoftERS.Reports">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>

                                                <telerik:RadGrid ID="RadGridEUS" runat="server" Skin="Office2010Blue" GroupPanelPosition="Top" AutoGenerateColumns="False" CellSpacing="-1" PagerStyle-AlwaysVisible="true" ExportSettings-Excel-Format="XLSX" ExportSettings-ExportOnlyData="true">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                                        <Selecting CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                                        <%--<ClientEvents OnCellSelected="SelectCellEUS"></ClientEvents>--%>
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="Endoscopist1" ClientDataKeyNames="AnonimizedID" CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                                                        <CommandItemSettings ExportToExcelText="Export" ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="AnonimizedID" Display="false" DataType="System.String" UniqueName="AnonimizedID">
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Endoscopist1" DataType="System.Int32" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist name" ReadOnly="True" SortExpression="Endoscopist1" UniqueName="Endoscopist1">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridHyperLinkColumn DataTextField="NumberOfProcedures" DataType="System.Int32" FilterControlAltText="Filter Number of cases per year column" HeaderText="Number of cases per year" SortExpression="NumberOfProcedures" UniqueName="NumberOfProcedures" ColumnGroupName="Selectable" DataNavigateUrlFormatString="javascript:OpenDetails('EUS', '{0}')" DataNavigateUrlFields="AnonimizedID">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridHyperLinkColumn>        
                                                            
                                                            <%--<telerik:GridBoundColumn DataField="AntibioticP" DataType="System.Decimal" FilterControlAltText="Filter Antibiotics column" HeaderText="Prophylactic antibiotics before EUS guided puncture of cystic lesions" ReadOnly="True" SortExpression="AntibioticP" UniqueName="AntibioticP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>--%>

                                                            <%--<telerik:GridBoundColumn DataField="FNABiopsyP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter FNA column" HeaderText="Frequency of obtaining a diagnostic tissue sample in EUS FNA or FNB (fine needle biopsy) of solid lesions" ReadOnly="True" SortExpression="FNABiopsyP" UniqueName="FNABiopsyP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>--%>


                                                            <telerik:GridBoundColumn DataField="MedianSedationRateLT70Years_Midazolam" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Midazolam column" HeaderText="Median dose (Age <70) Midazolam" ReadOnly="True" SortExpression="MedianSedationRateLT70Years_Midazolam" UniqueName="MedianSedationRateLT70Years_Midazolam" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateLT70Years_Pethidine" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Pethidine column" HeaderText="Median dose (Age <70) Pethidine" ReadOnly="True" SortExpression="MedianAnalgesiaRateLT70Years_Pethidine" UniqueName="MedianAnalgesiaRateLT70Years_Pethidine" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateLT70Years_Fentanyl" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Fentanyl column" HeaderText="Median dose (Age <70) Fentanyl" ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfort" UniqueName="MedianAnalgesiaRateLT70Years_Fentanyl" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianSedationRateGE70Years_Midazolam" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Midazolam column" HeaderText="Median dose (Age >70) Midazolam" ReadOnly="True" SortExpression="MedianSedationRateGE70Years_Midazolam" UniqueName="MedianSedationRateGE70Years_Midazolam" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateGE70Years_Pethidine" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Pethidine column" HeaderText="Median dose (Age >70) Pethidine" ReadOnly="True" SortExpression="MedianAnalgesiaRateGE70Years_Pethidine" UniqueName="MedianAnalgesiaRateGE70Years_Pethidine" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="MedianAnalgesiaRateGE70Years_Fentanyl" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age >70) Fentanyl column" HeaderText="Median dose (Age >70) Fentanyl" ReadOnly="True" SortExpression="MedianAnalgesiaRateGE70Years_Fentanyl" UniqueName="MedianAnalgesiaRateGE70Years_Fentanyl" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PropofolP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter % of procedures performed with propofol column" HeaderText="% of procedures performed with propofol" ReadOnly="True" SortExpression="PropofolP" UniqueName="PropofolP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ComfortLevelModerateSevereDiscomfort" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Comfort rate % moderate or severe discomfort column" HeaderText="Endoscopist comfort rate % moderate or severe discomfort" ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfort" UniqueName="ComfortLevelModerateSevereDiscomfort" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ComfortLevelModerateSevereDiscomfortNurse" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Comfort rate % moderate or severe discomfort column" HeaderText="Nurse comfort rate % moderate or severe discomfort" ReadOnly="True" SortExpression="ComfortLevelModerateSevereDiscomfortNurse" UniqueName="ComfortLevelModerateSevereDiscomfortNurse" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="GTRecommededDose" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Greater than recommended dose of sedation column" HeaderText="Greater than recommended dose of sedation" ReadOnly="True" SortExpression="GTRecommededDose" UniqueName="GTRecommededDose" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoSedationP" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter Unsedated procedures in % column" HeaderText="Unsedated procedures in %" ReadOnly="True" SortExpression="NoSedationP" UniqueName="NoSedationP" ColumnGroupName="UnSelectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>


                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageEndoscopists" runat="server">
                                            <div class="jagDivGrid">
                                                <%--<h1>JAG/GRS Report: Consultants</h1>--%>
                                                <telerik:RadContextMenu ID="RadContextMenuCON" runat="server" OnClientItemClicked="getContextMenuCON">
                                                    <Targets>
                                                        <telerik:ContextMenuControlTarget ControlID="RadGridEndoscopists" />
                                                        <telerik:ContextMenuElementTarget ElementID="" />
                                                    </Targets>
                                                    <Items>
                                                    </Items>
                                                </telerik:RadContextMenu>
                                                <asp:ObjectDataSource ID="DSEndoscopists" runat="server" SelectMethod="GetConsultantsQry" TypeName="UnisoftERS.Reports">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridEndoscopists" runat="server" Skin="Office2010Blue" AutoGenerateColumns="False" GroupPanelPosition="Top" PagerStyle-AlwaysVisible="true">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                                        <Selecting CellSelectionMode="SingleCell" EnableDragToSelectRows="True"></Selecting>
                                                        <%--<ClientEvents OnCellSelected="SelectCellCON"></ClientEvents>--%>
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="UserID" CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                                                        <CommandItemSettings ExportToExcelText="Export" ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="UserID" DataType="System.Int32" FilterControlAltText="Filter UserID column" HeaderText="User ID" ReadOnly="True" SortExpression="UserID" UniqueName="UserID">
                                                                <HeaderStyle HorizontalAlign="Center" CssClass="div50" />
                                                                <ItemStyle HorizontalAlign="Center" CssClass="div50" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Consultant" FilterControlAltText="Filter Consultant column" HeaderText="Consultant" ReadOnly="True" SortExpression="Consultant" UniqueName="Consultant">
                                                                <HeaderStyle HorizontalAlign="Left" />
                                                                <ItemStyle HorizontalAlign="Left" />
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                        <GroupHeaderItemStyle Wrap="True" />
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                    </telerik:RadMultiPage>
                                    <%--                                                </td>
                                            </tr>
                                        </table>--%>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>


                </asp:Panel>
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Animation="Fade" AutoSize="true" Modal="True" RenderMode="Classic" VisibleStatusbar="False" Skin="Metro" MinHeight="500px" MinWidth="650px">
            <Windows>
                <telerik:RadWindow ID="RadWindow1" runat="server" Height="600" Width="950" AutoSize="false" CssClass="rad-window-popup" VisibleStatusbar="false" ReloadOnShow="true" />
            </Windows>
        </telerik:RadWindowManager>
    </div>

    <telerik:RadScriptBlock runat="server">


        <script type="text/javascript" src="../../Scripts/Reports.js"></script>
        <script type="text/javascript">
            var docURL = document.URL;
            var grid;
            var OGD = {}
            OGD.columnName = "";
            OGD.rowID = "";
            var PEG = {}
            PEG.columnName = "";
            PEG.rowID = "";
            var ERC = {}
            ERC.columnName = "";
            ERC.rowID = "";
            var SIG = {}
            SIG.columnName = "";
            SIG.rowID = "";
            var EUS = {}
            EUS.columnName = "";
            EUS.rowID = "";
            var COL = {}
            COL.columnName = "";
            COL.rowID = "";
            var Bowel = {}
            Bowel.columnName = "";
            Bowel.rowID = "";
            var BPB = {}
            BPB.columnName = "";
            BPB.rowID = "";
            var CON = {}
            CON.columnName = "";
            CON.rowID = "";

            function getReportTarget(rti) {
                var res;
                var jsondata = {
                    ReportID: rti
                };
                $.ajax({
                    type: "POST",
                    async: false,
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getReportTarget",
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) { res = msg.d; },
                });
                return res;
            }

            function getDefaultColumnReport(pt, cn) {
                var res;
                var jsondata = {
                    Group: pt,
                    columnName: cn
                };
                $.ajax({
                    type: "POST",
                    async: false,
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getDefaultColumnReport",
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) { res = msg.d; },
                });
                return res;
            }

            function getMenuXML(pt, cn) {
                var res;
                var jsondata = {
                    Group: pt,
                    columnName: cn
                };
                $.ajax({
                    type: "POST",
                    async: false,
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getMenuXML",
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) { res = msg.d; },
                });
                return res;
            }
            function getContextMenuOGD(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, OGD.columnName, OGD.rowID);
            }
            function getContextMenuPEG(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, PEG.columnName, PEG.rowID);
            }
            function getContextMenuERC(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, ERC.columnName, ERC.rowID);
            }
            function getContextMenuSIG(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, SIG.columnName, SIG.rowID);
            }
            function getContextMenuEUS(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, EUS.columnName, EUS.rowID);
            }
            function getContextMenuCOL(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, COL.columnName, COL.rowID);
            }
            function getContextMenuBowel(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, Bowel.columnName, Bowel.rowID);
            }
            function getContextMenuBPB(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, BPB.columnName, BPB.rowID);
            }
            function getContextMenuCON(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, CON.columnName, CON.rowID);
            }

            function loadBreakdownReport(rowID, columnName, procedureTypeId) {
                Unisoft.PopUpWindow(rowID, columnName, procedureTypeId);
            }

            function SelectCellOGD(sender, args) {
                var isSelectable = args.get_column().get_columnGroupName() === "Selectable";
                columnName = args.get_column().get_uniqueName();
                rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
                $find("<%= RadContextMenuOGD.ClientID%>").get_items().clear();
                var menuOGD = $find("<%= RadContextMenuOGD.ClientID%>");
                text = getMenuXML('OGD', columnName);
                parser = new DOMParser();
                xmlDoc = parser.parseFromString(text, "text/xml");
                var key = "OGD" + columnName;
                x = xmlDoc.documentElement.getElementsByTagName("row");
                var MenuText = "";
                var MenuValue = "";
                var MenuToolTip = "";
                for (var i = 0; i < x.length; i++) {
                    MenuText = x[i].getAttribute("Text");
                    MenuValue = x[i].getAttribute("Value");
                    MenuToolTip = x[i].getAttribute("ToolTip");
                    AddNewOGDItem(MenuText, MenuValue, MenuToolTip);
                }
                OGD.columnName = columnName;
                OGD.rowID = rowID;

                if (isSelectable) {
                    loadBreakdownReport(rowID, columnName, 1);
                }
                return false;
            }
            function SelectCellPEG(sender, args) {
                var isSelectable = args.get_column().get_columnGroupName() === "Selectable";
                columnName = args.get_column().get_uniqueName();
                rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
                $find("<%= RadContextMenuPEG.ClientID%>").get_items().clear();
                var menuPEG = $find("<%= RadContextMenuPEG.ClientID%>");
                var text = '' + getMenuXML('PEG', columnName);
                if (text == '') {
                } else {
                    var parser = new DOMParser();
                    var xmlDoc = parser.parseFromString(text, "text/xml");
                    var key = "PEG" + PEG.columnName;
                    var x = xmlDoc.documentElement.getElementsByTagName("row");
                    var MenuText = "";
                    var MenuValue = "";
                    var MenuToolTip = "";
                    for (var i = 0; i < x.length; i++) {
                        MenuText = x[i].getAttribute("Text");
                        MenuValue = x[i].getAttribute("Value");
                        MenuToolTip = x[i].getAttribute("ToolTip");
                        AddNewPEGItem(MenuText, MenuValue, MenuToolTip);
                    }
                }
                PEG.columnName = columnName;
                PEG.rowID = rowID;

                if (isSelectable) {
                    loadBreakdownReport(rowID, columnName, 15);
                }
                return false;
            }
            function SelectCellERC(sender, args) {
                var isSelectable = args.get_column().get_columnGroupName() === "Selectable";
                columnName = args.get_column().get_uniqueName();
                rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
                $find("<%= RadContextMenuERC.ClientID%>").get_items().clear();
                var menuERC = $find("<%= RadContextMenuERC.ClientID%>");
                var text = '' + getMenuXML('ERC', columnName);
                if (text == '') {
                } else {
                    var parser = new DOMParser();
                    var xmlDoc = parser.parseFromString(text, "text/xml");
                    var key = "ERC" + ERC.columnName;
                    var x = xmlDoc.documentElement.getElementsByTagName("row");
                    var MenuText = "";
                    var MenuValue = "";
                    var MenuToolTip = "";
                    for (var i = 0; i < x.length; i++) {
                        MenuText = x[i].getAttribute("Text");
                        MenuValue = x[i].getAttribute("Value");
                        MenuToolTip = x[i].getAttribute("ToolTip");
                        AddNewERCItem(MenuText, MenuValue, MenuToolTip);
                    }
                }
                ERC.columnName = columnName;
                ERC.rowID = rowID;

                if (isSelectable) {
                    loadBreakdownReport(rowID, columnName, 2);
                }
                return false;
            }
            function SelectCellSIG(sender, args) {
                var isSelectable = args.get_column().get_columnGroupName() === "Selectable";
                columnName = args.get_column().get_uniqueName();
                rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
                $find("<%= RadContextMenuSIG.ClientID%>").get_items().clear();
                var menuSIG = $find("<%= RadContextMenuSIG.ClientID%>");
                var text = '' + getMenuXML('SIG', columnName);
                if (text == '') {
                } else {
                    var parser = new DOMParser();
                    var xmlDoc = parser.parseFromString(text, "text/xml");
                    var key = "SIG" + SIG.columnName;
                    var x = xmlDoc.documentElement.getElementsByTagName("row");
                    var MenuText = "";
                    var MenuValue = "";
                    var MenuToolTip = "";
                    for (var i = 0; i < x.length; i++) {
                        MenuText = x[i].getAttribute("Text");
                        MenuValue = x[i].getAttribute("Value");
                        MenuToolTip = x[i].getAttribute("ToolTip");
                        AddNewSIGItem(MenuText, MenuValue, MenuToolTip);
                    }
                }
                SIG.columnName = columnName;
                SIG.rowID = rowID;

                if (isSelectable) {
                    loadBreakdownReport(rowID, columnName, 4);
                }
                return false;
            }
            function SelectCellEUS(sender, args) {
                var isSelectable = args.get_column().get_columnGroupName() === "Selectable";
                columnName = args.get_column().get_uniqueName();
                rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
                $find("<%= RadContextMenuEUS.ClientID%>").get_items().clear();
                var menuEUS = $find("<%= RadContextMenuEUS.ClientID%>");
                var text = '' + getMenuXML('EUS', columnName);
                if (text == '') {
                } else {
                    var parser = new DOMParser();
                    var xmlDoc = parser.parseFromString(text, "text/xml");
                    var key = "EUS" + EUS.columnName;
                    var x = xmlDoc.documentElement.getElementsByTagName("row");
                    var MenuText = "";
                    var MenuValue = "";
                    var MenuToolTip = "";
                    for (var i = 0; i < x.length; i++) {
                        MenuText = x[i].getAttribute("Text");
                        MenuValue = x[i].getAttribute("Value");
                        MenuToolTip = x[i].getAttribute("ToolTip");
                        AddNewEUSItem(MenuText, MenuValue, MenuToolTip);
                    }
                }
                EUS.columnName = columnName;
                EUS.rowID = rowID;

                if (isSelectable) {
                    loadBreakdownReport(rowID, columnName, 4);
                }
                return false;
            }
            function SelectCellCOL(sender, args) {
                var isSelectable = args.get_column().get_columnGroupName() === "Selectable";
                columnName = args.get_column().get_uniqueName();
                rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
                $find("<%= RadContextMenuCOL.ClientID%>").get_items().clear();
                var menuCOL = $find("<%= RadContextMenuCOL.ClientID%>");
                var text = '' + getMenuXML('COL', columnName);
                if (text == '') {
                } else {
                    var parser = new DOMParser();
                    var xmlDoc = parser.parseFromString(text, "text/xml");
                    var key = "COL" + COL.columnName;
                    var x = xmlDoc.documentElement.getElementsByTagName("row");
                    var MenuText = "";
                    var MenuValue = "";
                    var MenuToolTip = "";
                    for (var i = 0; i < x.length; i++) {
                        MenuText = x[i].getAttribute("Text");
                        MenuValue = x[i].getAttribute("Value");
                        MenuToolTip = x[i].getAttribute("ToolTip");
                        AddNewCOLItem(MenuText, MenuValue, MenuToolTip);
                    }
                }
                COL.columnName = columnName;
                COL.rowID = rowID;

                if (isSelectable) {
                    loadBreakdownReport(rowID, columnName, 3);
                }
                return false;
            }
            function SelectCellBowel(sender, args) {
                columnName = args.get_column().get_uniqueName();
                rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
                $find("<%= RadContextMenuBowel.ClientID%>").get_items().clear();
                var menuBowel = $find("<%= RadContextMenuBowel.ClientID%>");
                var text = '' + getMenuXML('Bowel', columnName);
                if (text == '') {
                } else {
                    var parser = new DOMParser();
                    var xmlDoc = parser.parseFromString(text, "text/xml");
                    var key = "Bowel" + Bowel.columnName;
                    var x = xmlDoc.documentElement.getElementsByTagName("row");
                    var MenuText = "";
                    var MenuValue = "";
                    var MenuToolTip = "";
                    for (var i = 0; i < x.length; i++) {
                        MenuText = x[i].getAttribute("Text");
                        MenuValue = x[i].getAttribute("Value");
                        MenuToolTip = x[i].getAttribute("ToolTip");
                        AddNewBowelItem(MenuText, MenuValue, MenuToolTip);
                    }
                }
                Bowel.columnName = columnName;
                Bowel.rowID = rowID;


                return false;
            }
            function SelectCellCON(sender, args) {
                columnName = args.get_column().get_uniqueName();
                rowID = args.get_gridDataItem().getDataKeyValue("AnonimizedID");
                $find("<%= RadContextMenuCON.ClientID%>").get_items().clear();
                var menuCON = $find("<%= RadContextMenuCON.ClientID%>");
                var text = '' + getMenuXML('CON', columnName);
                if (text == '') {
                } else {
                    var parser = new DOMParser();
                    var xmlDoc = parser.parseFromString(text, "text/xml");
                    var key = "CON" + CON.columnName;
                    var x = xmlDoc.documentElement.getElementsByTagName("row");
                    var MenuText = "";
                    var MenuValue = "";
                    var MenuToolTip = "";
                    for (var i = 0; i < x.length; i++) {
                        MenuText = x[i].getAttribute("Text");
                        MenuValue = x[i].getAttribute("Value");
                        MenuToolTip = x[i].getAttribute("ToolTip");
                        AddNewCONItem(MenuText, MenuValue, MenuToolTip);
                    }
                }
                CON.columnName = columnName;
                CON.rowID = rowID;


                return false;
            }

            function AddNewOGDItem(Text, Value, ToolTip) {
                var menuOGD = $find("<%=RadContextMenuOGD.ClientID%>");
                var menuItem = new Telerik.Web.UI.RadMenuItem();
                menuItem.get_value.Value = Value;
                menuItem.ToolTip = ToolTip;
                menuItem.set_text(Text);
                menuItem.set_value(Value);
                menuOGD.trackChanges();
                menuOGD.get_items().add(menuItem);
                menuOGD.commitChanges();
            }
            function AddNewPEGItem(Text, Value, ToolTip) {
                var menuPEG = $find("<%=RadContextMenuPEG.ClientID%>");
                var menuItem = new Telerik.Web.UI.RadMenuItem();
                menuItem.get_value.Value = Value;
                menuItem.ToolTip = ToolTip;
                menuItem.set_text(Text);
                menuItem.set_value(Value);
                menuPEG.trackChanges();
                menuPEG.get_items().add(menuItem);
                menuPEG.commitChanges();
            }
            function AddNewERCItem(Text, Value, ToolTip) {
                var menuERC = $find("<%=RadContextMenuERC.ClientID%>");
                var menuItem = new Telerik.Web.UI.RadMenuItem();
                menuItem.get_value.Value = Value;
                menuItem.ToolTip = ToolTip;
                menuItem.set_text(Text);
                menuItem.set_value(Value);
                menuERC.trackChanges();
                menuERC.get_items().add(menuItem);
                menuERC.commitChanges();
            }
            function AddNewSIGItem(Text, Value, ToolTip) {
                var menuSIG = $find("<%=RadContextMenuSIG.ClientID%>");
                var menuItem = new Telerik.Web.UI.RadMenuItem();
                menuItem.get_value.Value = Value;
                menuItem.ToolTip = ToolTip;
                menuItem.set_text(Text);
                menuItem.set_value(Value);
                menuSIG.trackChanges();
                menuSIG.get_items().add(menuItem);
                menuSIG.commitChanges();
            }
            function AddNewCOLItem(Text, Value, ToolTip) {
                var menuCOL = $find("<%=RadContextMenuCOL.ClientID%>");
                var menuItem = new Telerik.Web.UI.RadMenuItem();
                menuItem.get_value.Value = Value;
                menuItem.ToolTip = ToolTip;
                menuItem.set_text(Text);
                menuItem.set_value(Value);
                menuCOL.trackChanges();
                menuCOL.get_items().add(menuItem);
                menuCOL.commitChanges();
            }
            function AddNewBowelItem(Text, Value, ToolTip) {
                var menuBowel = $find("<%=RadContextMenuBowel.ClientID%>");
                var menuItem = new Telerik.Web.UI.RadMenuItem();
                menuItem.get_value.Value = Value;
                menuItem.ToolTip = ToolTip;
                menuItem.set_text(Text);
                menuItem.set_value(Value);
                menuBowel.trackChanges();
                menuBowel.get_items().add(menuItem);
                menuBowel.commitChanges();
            }
            function AddNewCONItem(Text, Value, ToolTip) {
                var menuCON = $find("<%=RadContextMenuCON.ClientID%>");
                var menuItem = new Telerik.Web.UI.RadMenuItem();
                menuItem.get_value.Value = Value;
                menuItem.ToolTip = ToolTip;
                menuItem.set_text(Text);
                menuItem.set_value(Value);
                menuCON.trackChanges();
                menuCON.get_items().add(menuItem);
                menuCON.commitChanges();
            }
            function ResetPage(sender, args) {
                setTimeout(function () {
                    window.location.reload();
                }, 100); 
            }
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

            $(document).ready(function () {
                $("#loaderPreview").hide().delay(1000);
                $("#AllOf").hide();
                $("#Since_wrapper").hide();
                $("#lbFor").hide();
                $("#n").hide();
                $("#DWMQY").hide();
                $("#selectAll").change(function () {
                    $("#EndoList :checkbox").prop('checked', $(this).prop("checked"));
                });

                $(".consultant-search").on('keyup', function () {
                    var item;
                    var search;
                    search = $(this).val(); //get textBox value
                    var availableUserList = $find("<%=RadListBox1.ClientID%>"); //Get RadList
                    if (search.length > 0) {
                        for (var i = 0; i < availableUserList._children.get_count(); i++) {
                            if (availableUserList.getItem(i).get_text().toLowerCase().match(search.toLowerCase())) {
                                availableUserList.getItem(i).select();
                            }
                            else {
                                availableUserList.getItem(i).unselect();
                            }
                        }
                    }
                    else {
                        availableUserList.clearSelection();
                        availableUserList.selectedIndex = -1;
                    }
                });
                $.extend($.expr[":"],
                    {
                        "contains-ci": function (elem, i, match, array) {
                            return (elem.TextContent || elem.innerText || $(elem).text() || "").toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
                        }
                    });
                $("#TypeOfConsultant_0").change(function () {
                    $("#EndoList .USNcb").show();
                    $("#EndoList .USNcb").find(":checkbox").prop('checked', false);
                });
                $("#TypeOfConsultant_1").change(function () {
                    $("#EndoList .E1True").show();
                    $("#EndoList .E1False").find(":checkbox").prop('checked', false);
                    $("#EndoList .E1False").hide();
                });
                $("#TypeOfConsultant_2").change(function () {
                    $("#EndoList .E2True").show();
                    $("#EndoList .E2False").find(":checkbox").prop('checked', false);
                    $("#EndoList .E2False").hide();
                });
                $("#TypeOfConsultant_3").change(function () {
                    $("#EndoList .LCTrue").show();
                    $("#EndoList .LCFalse").find(":checkbox").prop('checked', false);
                    $("#EndoList .LCFalse").hide();
                });
                $("#TypeOfConsultant_4").change(function () {
                    $("#EndoList .ASTrue").show();
                    $("#EndoList .ASFalse").find(":checkbox").prop('checked', false);
                    $("#EndoList .ASFalse").hide();
                });
                $("#TypeOfConsultant_5").change(function () {
                    $("#EndoList .N1True").show();
                    $("#EndoList .N1False").find(":checkbox").prop('checked', false);
                    $("#EndoList .N1False").hide();
                });
                $("#TypeOfConsultant_6").change(function () {
                    $("#EndoList .N2True").show();
                    $("#EndoList .N2False").find(":checkbox").prop('checked', false);
                    $("#EndoList .N2False").hide();
                });
                $("#TypeOfPeriod_0").change(function () {
                    $("#AllOf").hide();
                    $("#Since_wrapper").hide();
                    $("#lbFor").hide();
                    $("#n").hide();
                    $("#DWMQY").hide();
                });
                $("#TypeOfPeriod_1").change(function () {
                    $("#AllOf").show();
                    $("#Since_wrapper").show();
                    $("#lbFor").hide();
                    $("#n").hide();
                    $("#DWMQY").hide();
                });
                $("#TypeOfPeriod_2").change(function () {
                    $("#AllOf").hide();
                    $("#Since_wrapper").show();
                    $("#lbFor").hide();
                    $("#n").hide();
                    $("#DWMQY").hide();
                });
                $("#TypeOfPeriod_3").change(function () {
                    $("#AllOf").hide();
                    $("#Since_wrapper").show();
                    $("#lbFor").show();
                    $("#n").show();
                    $("#DWMQY").show();
                });
                $("#TypeOfPeriod_4").change(function () {
                    $("#AllOf").hide();
                    $("#Since_wrapper").hide();
                    $("#lbFor").hide();
                    $("#n").show();
                    $("#DWMQY").show();
                });
                $("#form1").fadeIn("slow");

                $("#<%=RadButtonFilter.ClientID%>").click(function (e, args) {
                    //showLoad();
                    //$("#loaderPreview").show().delay(1000);
                });

                $("#RadContextMenuOGD");
                $("#RadContextMenuPEG");
                $("#RadContextMenuERC");
                $("#RadContextMenuSIG");
                $("#RadContextMenuCOL");
                $("#RadContextMenuBowel");
                $("#RadContextMenuEUS");
                $("#RadContextMenuCON");
                $("#cbHideSuppressed").change(function () {
                    formChange();
                });
                $("#ComboConsultants_Input").change(function () {
                    formChange();
                });
            });

            function hideLoad() {
               <%-- var currentUpdatedControl = "<%= RadTabStrip1.ClientID %>";
                var currentLoadingPanel = $find("<%= RadAjaxLoadingPanel1.ClientID %>");
                currentLoadingPanel.hide(currentUpdatedControl);--%>
            }
            function showLoad() {
               <%-- var currentLoadingPanel = $find("<%= RadAjaxLoadingPanel1.ClientID %>");
                var currentUpdatedControl = "<%= RadTabStrip1.ClientID %>";
                currentLoadingPanel.show(currentUpdatedControl);--%>
            }

            //$("#form1").fadeOut("slow");
            function formChange() {
                $("#ISMFilter").val("");
                ct = $("#ComboConsultants_Input").val();
                var cb = document.getElementById("<%=cbHideSuppressed.ClientID%>").checked;
                var hs = "";
                if (cb === true) {
                    hs = "1";
                } else {
                    hs = "0";
                }
                var listbox1 = $find("<%=RadListBox1.ClientID%>");
                var item1 = new Telerik.Web.UI.RadListBoxItem();
                var ItemsNo1 = listbox1.get_items().get_count();
                var usr = document.getElementById("<%=SUID.ClientID%>").value;
                var text = getConsultants("1", ct, "1", usr);
                var parser = new DOMParser();
                var xmlDoc = parser.parseFromString(text, "text/xml");
                x = xmlDoc.documentElement.getElementsByTagName("row");
                var Consultant = "";
                var ReportID = "";
                listbox1.get_items().clear();
                for (var i = 0; i < x.length; i++) {
                    Consultant = x[i].getAttribute("Consultant");
                    ReportID = x[i].getAttribute("ReportID");
                    var item1 = new Telerik.Web.UI.RadListBoxItem();
                    item1.set_text(Consultant);
                    item1.set_value(ReportID);
                    listbox1.get_items().add(item1);
                }
            <%--var listbox2 = $find("<%=RadListBox2.ClientID%>");
            var item2 = new Telerik.Web.UI.RadListBoxItem();
            var ItemsNo2 = listbox2.get_items().get_count();
            listbox2.get_items().clear();--%>
            }
            function getConsultants(lb, ct, hs, usr) {
                var docURL = document.URL;
                var res;
                var jsondata = {
                    listboxNo: lb,
                    ConsultantType: ct,
                    HideSuppressed: hs,
                    UserID: usr
                };
                $.ajax({
                    type: "POST",
                    async: false,
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getConsultants",
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        console.log(msg.d);
                        res = msg.d;
                    },
                    error: function (request, status, error) {
                        console.log(request.responseText);
                    }
                });
                return res;
            }

            $(".collapsible_header").click(function () {

                $header = $(this);
                //getting the next element
                $content = $header.next();
                //open up the content needed - toggle the slide- if visible, slide up, if not slidedown.
                $content.slideToggle(500, function () {
                    var $arrowSpan = $header.find('img');
                    if ($content.is(":visible")) {
                        $arrowSpan.attr("src", "../../Images/icons/collapse-arrow-down.png");
                    } else {
                        $arrowSpan.attr("src", "../../Images/icons/collapse-arrow-up.png");
                    }
                });
            });

            function OpenDetails(procType, ConsultantId) {
                var url = "<%= ResolveUrl("~/Products/Reports/DrillDown.aspx?procType={0}&consultantId={1}")%>";
                url = url.replace("{0}", procType);
                url = url.replace("{1}", ConsultantId);
                var oWnd = $find("<%= RadWindow1.ClientID %>");

                oWnd._navigateUrl = url;
                oWnd.SetSize(1200, 500);
                oWnd.show();
            }

        </script>
    </telerik:RadScriptBlock>

</asp:Content>
