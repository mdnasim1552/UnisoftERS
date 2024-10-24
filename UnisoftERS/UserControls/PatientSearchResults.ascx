<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PatientSearchResults.ascx.vb" Inherits="UnisoftERS.PatientSearchResults" %>
<style>
    .PatientGridClass .rgSelectedRow {
        background-color: #28a6e0 !important;
    }

    .RadGrid .rgWorklistPatient {
        color: #ffa31a !important;
    }

    .PatientGridClass .rgDataDiv {
        height: auto !important;
        max-height: 650px;        
    }

    .UGIPatient {
        font-style: italic;
        color: grey;
    }
</style>
<div id="PatientsGridSection" runat="server" style="padding-left: 0px; padding-right: 15px; width: 97%" visible="false">
    <asp:ObjectDataSource ID="PatientsObjectDataSource" runat="server"
        TypeName="UnisoftERS.DataAccess" SelectMethod="GetPatients">
        <SelectParameters>
            <asp:Parameter Name="SearchString1" DbType="String" />
            <asp:Parameter Name="SearchString2" DbType="String" />
            <asp:Parameter Name="SearchString3" DbType="String" />
            <asp:Parameter Name="SearchString4" DbType="String" />
            <asp:Parameter Name="SearchString5" DbType="String" />
            <asp:Parameter Name="SearchString6" DbType="String" />
            <asp:Parameter Name="SearchString7" DbType="String" />
            <asp:Parameter Name="SearchString8" DbType="String" />
            <asp:Parameter Name="opt_condition" DbType="String" />
            <asp:Parameter Name="opt_type" DbType="String" />
            <asp:Parameter Name="IncludeDeceased" DbType="Boolean" />
            <%--<asp:Parameter Name="ExcludeDeceased" DbType="Boolean" />--%>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:HiddenField ID="SelectedPatientHiddenField" runat="server" />
    <asp:HiddenField ID="PatientDatasource" runat="server" />
    <asp:HiddenField ID="SelectedPatientSourceHiddenField" runat="server" />
    <asp:HiddenField ID="radGridClickedRowIndex" runat="server" />
    <asp:HiddenField ID="CurrentUserIdHiddenField" runat="server" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="decorationZone" Skin="Metro" />
    <telerik:RadNotification ID="CreateProcRadNotifier" runat="server" Animation="Fade"
        EnableRoundedCorners="true" Title="<div class='aspxValidationSummaryHeader'>Patient could not be imported:</div>"
        TitleIcon="delete" Position="Center" LoadContentOn="PageLoad"
        AutoCloseDelay="7000">
        <ContentTemplate>
            <div id="createValDiv" class="aspxValidationSummary"></div>
        </ContentTemplate>
    </telerik:RadNotification>
    <telerik:RadGrid ID="PatientsGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" DataSourceID="PatientsObjectDataSource"
        Skin="Metro" PageSize="15" AllowPaging="true" GridLines="None" OnItemCommand="PatientsGrid_ItemCommand" AllowSorting="true" CssClass="PatientGridClass">
        <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
        <CommandItemStyle BackColor="WhiteSmoke" />
        <MasterTableView ShowHeadersWhenNoRecords="true" CommandItemDisplay="Top" DataKeyNames="CaseNoteNo,PatientId,ERSPatient,Deceased,NHSNo,Surname,Forename1,DOB" ClientDataKeyNames="PatientId,ERSPatient,Deceased,NHSNo,CreateUpdateMethod,Surname,Forename1,DOB" TableLayout="Fixed" EnableNoRecordsTemplate="true"
            CssClass="MasterClass" GridLines="None" ItemStyle-Height="28" AlternatingItemStyle-Height="28">
            <CommandItemTemplate>
                <table style="background: url('../Images/bgGridHeader.png') repeat-x 0 100%; width: 100%;">
                    <tr>
                        <td style="width: 180px;">
                            <telerik:RadLinkButton ID="StartPreAssessment" BorderStyle="None" runat="server" Text="Pre Assessment" OnClientClicked="startpreassessment" CommandName="startpreassessment" Skin="Office2010Blue">
                                <Icon Url="../Images/icons/help_faq.png" Top="5px" />
                            </telerik:RadLinkButton>
                        </td>
                        <td style="width: 180px;">
                            <telerik:RadLinkButton ID="StartProcedureLinkButton" BorderStyle="None" runat="server" Text="View / Start procedure" OnClientClicked="startProcedure" CommandName="startprocedure" Skin="Office2010Blue">
                                <Icon Url="../Images/icons/select.png" Top="5px" />
                            </telerik:RadLinkButton>
                        </td>
                        <td>
                            <telerik:RadLinkButton ID="AddToWorkListButton" BorderStyle="None" runat="server" Text="Add to worklist" OnClientClicked="showWorkListWindow" Skin="Office2010Blue">
                                <Icon Url="../Images/icons/worklist_add.png" Top="5px" />
                            </telerik:RadLinkButton>
                        </td>
                        <td>
                            <telerik:RadLinkButton ID="EditPatientDetails" BorderStyle="None" runat="server" Text="Edit Patient Details" OnClientClicked="editPatientDetails" Skin="Office2010Blue">
                                <Icon Url="../Images/icons/worklist_add.png" Top="5px" />
                            </telerik:RadLinkButton>
                        </td>
                    </tr>
                </table>
            </CommandItemTemplate>
            <Columns>
                <telerik:GridTemplateColumn HeaderText="Surname" SortExpression="Surname" HeaderStyle-Width="100px">
                    <ItemTemplate>
                        <asp:Label ID="PatientDeceasedLabel" runat="server" Text="&olcross;" Visible="false" Font-Bold="false" ForeColor="#ae7439" ToolTip="Deceased" />&nbsp;
                        <asp:Label ID="PatientSurname" runat="server" Text='<%#Eval("Surname") %>' />
                    </ItemTemplate>
                </telerik:GridTemplateColumn>
                <telerik:GridBoundColumn DataField="Surname" HeaderText="Surname" SortExpression="Surname" Visible="false"></telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="ForeName1" HeaderText="Forename" SortExpression="ForeName1" HeaderStyle-Width="100px">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="DOB" HeaderText="DOB" SortExpression="DOB" HeaderStyle-Width="60px" DataFormatString="{0:dd/MM/yyyy}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="Gender" HeaderText="Gender" SortExpression="Gender" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="Ethnicity" HeaderText="Ethnicity" SortExpression="Ethnicity" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="NHSNo" HeaderText="NHS no." SortExpression="NHSNo" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="CaseNoteNo" HeaderText="Hospital no." SortExpression="CaseNoteNo" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="Postcode" HeaderText="Postcode" SortExpression="Postcode" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="Address" HeaderText="Address line 1" SortExpression="Address" HeaderStyle-Width="250px">
                </telerik:GridBoundColumn>
            </Columns>
            <NoRecordsTemplate>
                <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" class="rgNoRecords" runat="server">
                    No patients found. Amend your search criteria. 
                </div>
            </NoRecordsTemplate>

        </MasterTableView>
        <PagerStyle Mode="NextPrevAndNumeric" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Patients {2} to {3} of {5}" AlwaysVisible="true" BackColor="#f9f9f9" />
        <ClientSettings EnableRowHoverStyle="true">
            <Selecting AllowRowSelect="true" />
            <Scrolling AllowScroll="true" UseStaticHeaders="true" />
            <ClientEvents OnGridCreated="togglePagerVisibility" OnRowContextMenu="showContextMenu" OnRowSelecting="rowSelected" OnRowClick="rowSelected" OnRowDblClick="startProcedure" />
        </ClientSettings>
        <AlternatingItemStyle BackColor="#fafafa" />
        <HeaderStyle BackColor="#f4f7f9" Font-Bold="true" Height="10" />
        <GroupingSettings CaseSensitive="false" />
        <SortingSettings SortedBackColor="ControlLight" />
    </telerik:RadGrid>

    <telerik:RadContextMenu ID="RadMenu1" runat="server"
        EnableRoundedCorners="true" EnableShadows="true">
        <Items>
            <telerik:RadMenuItem Text="Pre Assessment" ImageUrl="../Images/icons/help_faq.png" NavigateUrl="javascript:startpreassessment();">
            </telerik:RadMenuItem>
            <telerik:RadMenuItem Text="View / Start procedure" ImageUrl="../Images/icons/select.png" NavigateUrl="javascript:startProcedure();">
            </telerik:RadMenuItem>
            <telerik:RadMenuItem Text="Add to worklist" ImageUrl="../Images/icons/worklist_add.png" NavigateUrl="javascript:showWorkListWindow();">
            </telerik:RadMenuItem>
        </Items>
    </telerik:RadContextMenu>
</div>
<telerik:RadWindowManager ID="AddNewGPRadWindowManager" runat="server"
    Style="z-index: 7001" Behaviors="Close,Move" AutoSize="false" Skin="Metro" EnableShadow="true" Modal="true">
    <Windows>
        <telerik:RadWindow ID="AddToWorklistWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
            Width="700px" Height="300px" Title="Add patient to worklist" VisibleStatusbar="false" />
        <telerik:RadWindow ID="EditPatient" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
            Width="700px" Height="300px" Title="Add patient to worklist" VisibleStatusbar="false" />
    </Windows>
</telerik:RadWindowManager>
<telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
    <script type="text/javascript">
        function clearPatientList() {
            var view = $find('<%=PatientsGrid.ClientID%>').get_masterTableView();
            view.set_dataSource([]);
            view.dataBind();
        }
        function showWorkListWindow(sender, args) {

            var grid = $find("<%= PatientsGrid.ClientID%>");

            var row = grid.get_masterTableView().get_dataItems()[selectedRowIndex];
            var deceased = row.getDataKeyValue("Deceased");
            var nhsno = row.getDataKeyValue("NHSNo");
            var showWorkList = true;

            if (deceased == "True") {
                //create modal for window
                $('#masterValDiv', parent.document).html("Patient deceased so cannot be added to the worklist.");
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();
                showWorkList = false;
                if (args)
                    args.set_cancel(true);
            }
            //alert(nhsno);
            if (nhsno.trim().length == 0) {
                //create modal for window
                $('#masterValDiv', parent.document).html("Patient without NHSNo cannot be added to the worklist.");
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();
                showWorkList = false;
                if (args)
                    args.set_cancel(true);
            }
            if ($('#<%=SelectedPatientHiddenField.ClientID%>').val() == "") {

                //create modal for window
                $('#masterValDiv', parent.document).html("No patient selected. Please select from the list and try again.");
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();

                if (args)
                    args.set_cancel(true);
            }

            var id = $('#<%=SelectedPatientHiddenField.ClientID%>').val();

            var oWnd = $find("<%=AddToWorklistWindow.ClientID%>");
            if (showWorkList) {
                oWnd.SetSize("690", "420");
                oWnd._navigateUrl = "Options/AddToWorklist.aspx?PatientId=" + id + "&nhsno=" + nhsno
                oWnd.show();
            }

            if (args)
                args.set_cancel(true);
        }
        function startpreassessment(sender, args) {

            if ($('#<%=SelectedPatientHiddenField.ClientID%>').val() == "") {

                //create modal for window
                $('#masterValDiv', parent.document).html("No patient selected. Please select from the list and try again.");
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();

                args.set_cancel(true);
            }
            else {
                var masterTable = $find("<%= PatientsGrid.ClientID %>").get_masterTableView();
                //alert(masterTable.values());
                var selectedGridRow = masterTable.get_dataItems()[selectedRowIndex];
                var nhsno = selectedGridRow.getDataKeyValue("NHSNo");
                var surname = selectedGridRow.getDataKeyValue("Surname");
                var forename = selectedGridRow.getDataKeyValue("Forename1");
                var dob = selectedGridRow.getDataKeyValue("DOB");
                var message = "";
                var blnImportPatientViaAPI = false;
                if ($('#<%=PatientDatasource.ClientID%>').val() == "1") {
                    blnImportPatientViaAPI = true;
                }

                masterTable.fireCommand("startpreassessment", "")
            }
        }


        function refreshWorklist(arg) {
            var masterTable = $find("<%= PatientsGrid.ClientID %>").get_masterTableView();
            masterTable.fireCommand("addtoworklist", arg);
        }

        var selectedRowIndex;
        function rowSelected(sender, args) {
            $('#<%=SelectedPatientHiddenField.ClientID%>').val(args.getDataKeyValue("PatientId"));
            $('#<%=SelectedPatientSourceHiddenField.ClientID%>').val(args.getDataKeyValue("CreateUpdateMethod"));
            selectedRowIndex = args.get_itemIndexHierarchical();
        }

        function startProcedure(sender, args) {
            if ($('#<%=SelectedPatientHiddenField.ClientID%>').val() == "") {

                //create modal for window
                $('#masterValDiv', parent.document).html("No patient selected. Please select from the list and try again.");
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();

                args.set_cancel(true);
            }
            else {
                var masterTable = $find("<%= PatientsGrid.ClientID %>").get_masterTableView();
                //alert(masterTable.values());
                var selectedGridRow = masterTable.get_dataItems()[selectedRowIndex];
                var nhsno = selectedGridRow.getDataKeyValue("NHSNo");
                var surname = selectedGridRow.getDataKeyValue("Surname");
                var forename = selectedGridRow.getDataKeyValue("Forename1");
                var dob = selectedGridRow.getDataKeyValue("DOB");
                var message = "";
                var blnImportPatientViaAPI = false;
                if ($('#<%=PatientDatasource.ClientID%>').val() == "1") {
                    blnImportPatientViaAPI = true;
                }


                // Commented out check for NHS number

                //if (nhsno.trim().length == 0) {

                //    //show modal dialogue message
                //    if (dob.trim().length > 0) {
                //        dob = dob.slice(0, 10);
                //    }
                //    message = "Procedure can not be created for a patient without NHS No. Please check the below patient demographics and try again.<br><br><table border='0'><tr><td style='color:red;'>";
                //    message = message + "Surname : </td><td style='color:red;'>" + surname + "</td></tr><tr><td style='color:red;'>";
                //    message = message + "Forename : </td><td style='color:red;'>" + forename + "</td></tr><tr><td style='color:red;'>";
                //    message = message + "DOB : </td><td style='color:red;'>" + dob + "</td></tr></table>";

                //    $('#masterValDiv', parent.document).html(message);
                //    $('#ValidationNotification', parent.document).show();
                //    $('.validation-modal', parent.document).show();

                //    args.set_cancel(true);
                //}
                //else {
                    masterTable.fireCommand("startprocedure", "");
                //}

            }
        }
        function editPatientDetails(sender, args) {
            if ($('#<%=SelectedPatientHiddenField.ClientID%>').val() == "") {

                //create modal for window
                $('#masterValDiv', parent.document).html("No patient selected. Please select from the list and try again.");
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();
            }
            else {

                var id = $('#<%=SelectedPatientHiddenField.ClientID%>').val();
                var src = $('#<%=SelectedPatientSourceHiddenField.ClientID%>').val();
                if (src != '') {
                    //create modal for window
                    $('#masterValDiv', parent.document).html("Selected Patient was created via PAS and cannot be edited.");
                    $('#ValidationNotification', parent.document).show();
                    $('.validation-modal', parent.document).show();
                } else {
                    var oWnd = $find("<%=EditPatient.ClientID%>");
                    oWnd.SetSize("820", "570");
                    oWnd._navigateUrl = "Common/PatientDetails.aspx?patientID=" + id
                    oWnd.show();
                }
            }
        }

        function showContextMenu(sender, eventArgs) {
            $find('<%= PatientsGrid.ClientID %>').clearSelectedItems();
            var menu = $telerik.findControl(document, "RadMenu1");
            var evt = eventArgs.get_domEvent();
            if (evt.target.tagName == "INPUT" || evt.target.tagName == "A") {
                return;
            }

            var rowIndex = eventArgs.get_itemIndexHierarchical();
            var row = $find('<%= PatientsGrid.ClientID %>').get_masterTableView().get_dataItems()[rowIndex];
            row.set_selected(true);
            $('#<%=SelectedPatientHiddenField.ClientID%>').val(row.getDataKeyValue("PatientId"));

            if (menu.findItemByText("Add to worklist") != null) {
                var ersPatientId = row.getDataKeyValue("ERSPatient");
                var patientDeceased = row.getDataKeyValue("Deceased");
                var items = menu.get_items();
                var totalItems = items.get_count();

                if (ersPatientId == "0" || patientDeceased == "True")
                {
                    if (totalItems < 3) {
                        menu.get_items().getItem(1).hide();
                        menu.get_items().getItem(0).set_text("View procedure(s)");
                    }
                    else
                    {
                        menu.get_items().getItem(2).hide();
                        menu.get_items().getItem(1).set_text("View procedure(s)");
                    }
                }
                else
                {
                    if (totalItems < 3)
                    {
                        menu.get_items().getItem(1).set_text("Add to worklist");
                        menu.get_items().getItem(0).set_text("View / Start procedure");
                    }
                    else
                    {
                        menu.get_items().getItem(2).set_text("Add to worklist");
                        menu.get_items().getItem(0).set_text("Pre Assessment");
                        menu.get_items().getItem(1).set_text("View / Start procedure");
                    }
                }
            }

            menu.show(evt);
            evt.cancelBubble = true;
            evt.returnValue = false;

            if (evt.stopPropagation) {
                evt.stopPropagation();
                evt.preventDefault();
            }
        }

        function togglePagerVisibility(sender, args) {
            var grid = sender;
            var masterTable = grid.get_masterTableView();
            var pagerElement = $("#ctl00_BodyContentPlaceHolder_PatientResultsControl_PatientsGrid_ctl00_Pager");

            if (masterTable.get_dataItems().length > 0) {
                pagerElement.show();
            } else {
                pagerElement.hide();
            }
        }

    </script>
</telerik:RadCodeBlock>
