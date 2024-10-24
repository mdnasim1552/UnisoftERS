<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Worklist.ascx.vb" Inherits="UnisoftERS.Worklist" %>

<style>
    .WrkGridClass .rgSelectedRow {
        cursor: pointer;
    }

    .WrkGridClass .rgHoveredRow {
        cursor: pointer;
    }

    .rcbInput {
        height: 12px !important;
        line-height: 9px;
        padding: 0px
    }

    .WrkGridClass .rgDataDiv {
        height: 400px !important;
    }

    .row-colour-opacity {
        opacity: 0.8;
    }

    .booked-colour {
        color: #000000 !important;
    }

    .attended-colour {
        color: #000000 !important;
    }

    .arrived-colour {
        color: #000000 !important;
    }

    .cancelled-colour {
        color: #FFFFFF !important;
    }

    .dna-colour {
        color: #000000 !important;
    }

    .default-colour {
        color: #000000 !important;
    }

    #ctl00_BodyContentPlaceHolder_WorklistControl_ctl00 {
        margin-left: 10px;
        vertical-align: middle;
    }

    #ctl00_BodyContentPlaceHolder_WorklistControl_ExportToExcelButton {
        float: right;
    }
</style>
<telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ControlsRadPane"
    Skin="Metro" />
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

<div style="margin-bottom: 5px; padding-left: 0px; padding-right: 15px; width: 97%;">
    <telerik:RadDatePicker RenderMode="Lightweight" ID="StartDate" Width="160px" Height="25px" runat="server" DateInput-Label="From:" ShowPopupOnFocus="true">
    </telerik:RadDatePicker>
    <telerik:RadDatePicker RenderMode="Lightweight" ID="EndDate" Width="160px" Height="25px" runat="server" DateInput-Label="To:" ShowPopupOnFocus="true">
    </telerik:RadDatePicker>
    <telerik:RadButton RenderMode="Lightweight" ID="SearchButton" runat="server" Text="Search" Width="90px" OnClientClicked="test"></telerik:RadButton>
    <telerik:RadLabel runat="server" AssociatedControlID="ViewAllCheckbox" Text="View All:"></telerik:RadLabel>
    <telerik:RadCheckBox RenderMode="Lightweight" ID="ViewAllCheckbox" runat="server" OnCheckedChanged="ViewAllCheckbox_CheckedChanged" AutoPostBack="true"></telerik:RadCheckBox>
    <telerik:RadButton ID="ExportToExcelButton" runat="server" Text="Export" OnClick="ExportToExcelButton_Click" Skin="Metro">
        <Icon PrimaryIconUrl="../Images/icons/excel.png" />
    </telerik:RadButton>
</div>
<div id="WorklistGridSection" runat="server" style="padding-left: 0px; padding-right: 15px; width: 97%;">
    <telerik:RadGrid ID="WorkListGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
        AllowAutomaticDeletes="True" AutoSizeColumnsMode="Fill" AllowSorting="true" Height="537" RenderMode="Lightweight"
        Skin="Metro" GridLines="None" PageSize="15" AllowPaging="true" OnNeedDataSource="WorkListGrid_NeedDataSource" ExportSettings-IgnorePaging="true"
        OnItemCommand="WorklistGrid_ItemCommand" OnItemDataBound="WorkListGrid_ItemDataBound" CssClass="WrkGridClass">
        <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
        <CommandItemStyle BackColor="WhiteSmoke" />
        <ExportSettings Excel-Format="Html" ExportOnlyData="true" IgnorePaging="true"></ExportSettings>
        <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="UniqueId,PatientId,BookingTypeId,AppointmentStatusHDCKEY,RoomId" CommandItemDisplay="Top"
            DataKeyNames="UniqueId,PatientId,HospitalNumber,ERSPatient,AppointmentStatusHDCKEY,RoomId,StartDateTime,ProcedureTypeId" TableLayout="Fixed" CssClass="MasterClass"
            GridLines="None" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AllowFilteringByColumn="false" AllowPaging="false">
            <CommandItemSettings ShowExportToExcelButton="true" ExportToExcelText="Export" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
            <CommandItemTemplate>
                <table style="background-color: #ECF2F7; width: 100%;">
                    <tr>
                       <td style="width: 180px;">
                            <telerik:RadLinkButton ID="StartPreAssessment" BorderStyle="None" runat="server" Text="Pre Assessment" 
                                        OnClientClicked="startPreAssessmentFromWorklist" CommandName="startpreassessment" Skin="Office2010Blue">
                                <Icon Url="../Images/icons/help_faq.png" Top="5px" />
                            </telerik:RadLinkButton>
                        </td>
                        <td style="width: 180px;">
                            <telerik:RadLinkButton ID="StartProcedureLinkButton" BorderStyle="None" runat="server" Text="View / Start procedure"
                                OnClientClicked="startProcedureFromWorklist" CommandName="startprocedure" Skin="Metro">
                                <Icon Url="../Images/icons/select.png" Top="5px" />
                            </telerik:RadLinkButton>
                        </td>
                        <%--<td style="width: 130px;">
                            <telerik:RadLinkButton ID="EditWorklistLinkButton" BorderStyle="None" runat="server" Text="Edit worklist"
                                OnClientClicking="editWorklistPatient" CommandName="editworklist" Skin="Metro">
                                <Icon Url="../Images/icons/edit.png" Top="5px" />
                            </telerik:RadLinkButton>
                        </td>
                        <td>
                            <telerik:RadLinkButton ID="RemoveFromWorklistLinkButton" BorderStyle="None" runat="server" Text="Remove from worklist"
                                OnClientClicking="removeWorklistPatient" CommandName="remove" Skin="Metro">
                                <Icon Url="../Images/icons/Cancel.png" Top="5px" />
                            </telerik:RadLinkButton>
                        </td>--%>
                    </tr>
                </table>
            </CommandItemTemplate>
            <Columns>
                <telerik:GridTemplateColumn UniqueName="ArrowColumn" ItemStyle-HorizontalAlign="Center">
                    <ItemTemplate>
                        <img src="./../Images/grid-row-selector.png" style="display: none;" />
                    </ItemTemplate>
                    <HeaderStyle Width="20px" />
                </telerik:GridTemplateColumn>
                <telerik:GridBoundColumn DataField="Date" HeaderText="Date" SortExpression="Date" HeaderStyle-Width="80px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="CallInTime" HeaderText="Call-In Time" SortExpression="CallInTime" HeaderStyle-Width="95px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="AppointmentTime" HeaderText="Apt. Time" SortExpression="AppointmentTime" HeaderStyle-Width="60px">
                </telerik:GridBoundColumn>
                <telerik:GridTemplateColumn UniqueName="Alerts" HeaderText="Alerts" SortExpression="Alerts" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                    <ItemTemplate>
                        <asp:Image ID="imgAlerts" ImageUrl="../Images/icons/alert.png" Height="22" Width="22" Stretch="Fill" runat="server" Visible="false" ToolTip='<%#Eval("Alerts") %>' />
                    </ItemTemplate>
                </telerik:GridTemplateColumn>
                <telerik:GridBoundColumn UniqueName="AlertText" DataField="Alerts" HeaderText="Alert" SortExpression="Alerts" HeaderStyle-Width="60px" Visible="false">
                </telerik:GridBoundColumn>
                <telerik:GridTemplateColumn UniqueName="Notes" HeaderText="Notes" SortExpression="Notes" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                    <ItemTemplate>
                        <asp:Image ID="imgNotes" ImageUrl="../Images/alert_round.png" Height="22" Width="22" Stretch="Fill" runat="server" Visible="false" ToolTip='<%#Eval("Notes") %>' />
                    </ItemTemplate>
                </telerik:GridTemplateColumn>
                <telerik:GridBoundColumn UniqueName="NoteText" DataField="Notes" HeaderText="Note" SortExpression="Notes" HeaderStyle-Width="60px" Visible="false">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="Forename" HeaderText="Forename" SortExpression="Forename" HeaderStyle-Width="130px">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="Surname" HeaderText="Surname" SortExpression="Surname" AllowFiltering="true" HeaderStyle-Width="130px">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="Gender" HeaderText="Gender" SortExpression="Gender" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="78px">
                </telerik:GridBoundColumn>
                <telerik:GridDateTimeColumn DataField="DOB" HeaderText="DOB" SortExpression="DOB" HeaderStyle-Width="80px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridDateTimeColumn>
                <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="Hospital No" SortExpression="HospitalNumber" HeaderStyle-Width="100px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="NHSNo" HeaderText="NHS No" SortExpression="NHSNo" HeaderStyle-Width="85px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="Endoscopist" HeaderText="Endoscopist" SortExpression="Endoscopist" HeaderStyle-Width="150px">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="RoomName" HeaderText="Room" SortExpression="RoomName" HeaderStyle-Width="90px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure" SortExpression="ProcedureType" HeaderStyle-Width="100px">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="AppointmentSubject" HeaderText="Therapeutic" SortExpression="AppointmentSubject" HeaderStyle-Width="300px">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="Category" HeaderText="Category" SortExpression="Category" HeaderStyle-Width="100px">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="AppointmentStatus" HeaderText="Status" SortExpression="AppointmentStatus" HeaderStyle-Width="85px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="ArrivedTime" HeaderText="Arrived" SortExpression="ArrivedTime" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="InProgressTime" HeaderText="In Progress" SortExpression="InProgressTime" HeaderStyle-Width="85px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="RecoveryTime" HeaderText="Recovery" SortExpression="RecoveryTime" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="DischargeTime" HeaderText="Discharge" SortExpression="DischargeTime" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                </telerik:GridBoundColumn>
            </Columns>
            <NoRecordsTemplate>
                <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                    No patients found.
                </div>
            </NoRecordsTemplate>
        </MasterTableView>
        <PagerStyle Mode="NextPrevAndNumeric" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Patients {2} to {3} of {5}"
            AlwaysVisible="true" BackColor="#f9f9f9" />
        <GroupingSettings CaseSensitive="false" CollapseAllTooltip="Collapse all groups"></GroupingSettings>
        <ClientSettings EnableRowHoverStyle="true">
            <Resizing AllowColumnResize="true" ResizeGridOnColumnResize="true" AllowResizeToFit="true" />
            <Selecting AllowRowSelect="true" />
            <ClientEvents OnRowContextMenu="showContextMenuWrk" OnRowSelecting="worklistRowSelected" OnRowClick="worklistRowSelected"
                OnRowDblClick="startProcedureFromWorklist" OnRowDeselected="RowDeselected" OnRowSelected="RowSelected" />
            <Scrolling AllowScroll="true" UseStaticHeaders="true" />
        </ClientSettings>
        <AlternatingItemStyle BackColor="#fafafa" />
        <HeaderStyle BackColor="#f4f7f9" Font-Bold="true" Height="10" />
        <SortingSettings SortedBackColor="ControlLight" />
    </telerik:RadGrid>

    <asp:Panel ID="Panel1" runat="server">
        <asp:Timer ID="Timer1" runat="server" Interval="300000" OnTick="Timer1_Tick">
        </asp:Timer>
    </asp:Panel>

    <input type="hidden" id="WorklistSelectedIdHiddenField" name="WorklistSelectedIdHiddenField" />
    <input type="hidden" id="WorklistPatientHiddenField" name="WorklistPatientHiddenField" />
    <input type="hidden" id="WorklistProcedureIdHiddenField" name="WorklistProcedureIdHiddenField" />

    <telerik:RadContextMenu ID="RadMenu2" runat="server" EnableRoundedCorners="true" EnableShadows="true" OnItemClick="RadMenu2_ItemClick">
        <Items>
            <telerik:RadMenuItem Text="Pre Assessment" ImageUrl="../Images/icons/help_faq.png" NavigateUrl="javascript:startPreAssessmentFromWorklist();">
            </telerik:RadMenuItem>
            <telerik:RadMenuItem Text="View / Start procedure" ImageUrl="../Images/icons/select.png" NavigateUrl="javascript:startProcedureFromWorklist();" Value="Start">
            </telerik:RadMenuItem>
            <telerik:RadMenuItem Text="Edit" ImageUrl="../Images/icons/edit.png" NavigateUrl="javascript:editWorklistPatient();">
            </telerik:RadMenuItem>
            <%--<telerik:RadMenuItem Text="Remove" ImageUrl="../Images/icons/cancel.png" NavigateUrl="javascript:removeWorklistPatient();">
            </telerik:RadMenuItem>--%>
            <telerik:RadMenuItem Text="Mark Arrived" Value="BA">
            </telerik:RadMenuItem>
            <telerik:RadMenuItem Text="Mark Discharged" Value="DC">
            </telerik:RadMenuItem>
            <telerik:RadMenuItem Text="Mark DNA" Value="D">
            </telerik:RadMenuItem>
            <telerik:RadMenuItem Text="Mark Abandoned" Value="X">
            </telerik:RadMenuItem>
            <%--<telerik:RadMenuItem Text="Mark Cancelled" Value="C">
            </telerik:RadMenuItem>--%>
            <telerik:RadMenuItem Text="Mark Booked" Value="B">
            </telerik:RadMenuItem>
            <telerik:RadMenuItem Text="Go To Patient" NavigateUrl="javascript:goToPatient();" Value="GoToPatient">
            </telerik:RadMenuItem>
            <telerik:RadMenuItem Text="View In Schedule Lists" Value="goToScheduler" NavigateUrl="javascript:goToScheduler();">
            </telerik:RadMenuItem>
        </Items>
    </telerik:RadContextMenu>
</div>
<asp:ObjectDataSource ID="WorkListObjectDataSource" runat="server" SelectMethod="GetWorklistPatients"
    TypeName="UnisoftERS.DataAccess">
    <SelectParameters>
        <asp:Parameter Name="StartDate" Type="DateTime" />
        <asp:Parameter Name="EndDate" Type="DateTime" />
        <asp:Parameter Name="EndoscopistId" Type="Int32" />
    </SelectParameters>
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="EndoscopistsObjectDataSource" runat="server" SelectMethod="BuildEndoList" TypeName="UnisoftERS.Worklist" />
<asp:SqlDataSource ID="ProcedureTypesDataSource" runat="server" SelectCommand="SELECT ProcedureTypeId, ProcedureType FROM ERS_ProcedureTypes WHERE Suppressed = 0 ORDER BY ProcedureTypeId" />
<telerik:RadWindowManager ID="RadWindowManager1" runat="server"
    Style="z-index: 7001" Behaviors="Close,Move" AutoSize="false" Skin="Metro" EnableShadow="true" Modal="true">
    <Windows>
        <telerik:RadWindow ID="EditWorklistWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
            Width="690px" Height="420px" Title="Add patient to worklist" VisibleStatusbar="false" />
    </Windows>
</telerik:RadWindowManager>
<telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
    <script type="text/javascript">
        var docURL = document.URL;

        $(document).ready(function () {

        });

        function updateGrid(result) {
            var tableView = $find("<%= WorkListGrid.ClientID %>").get_masterTableView();
            tableView.set_dataSource(result);
            tableView.dataBind();
        }

        function worklistRowSelected(sender, args) {
            document.getElementById("WorklistPatientHiddenField").value = args.getDataKeyValue("PatientId");
        }

        function startProcedureFromWorklist(sender, args) {
            if (document.getElementById("WorklistPatientHiddenField").value == "") {
                try {
                    //create modal for window
                    $('#masterValDiv', parent.document).html("No patient selected. Please select from the list and try again.");
                    $('#ValidationNotification', parent.document).show();
                    $('.validation-modal', parent.document).show();

                    args.set_cancel(true);
                }
                catch (e) { }
            }
            else {
                var masterTable = $find("<%= WorkListGrid.ClientID %>").get_masterTableView();
                masterTable.fireCommand("startprocedure", args);
            }
        }
        function startPreAssessmentFromWorklist(sender, args) {
            if (document.getElementById("WorklistPatientHiddenField").value == "") {
                try {
                    //create modal for window
                    $('#masterValDiv', parent.document).html("No patient selected. Please select from the list and try again.");
                    $('#ValidationNotification', parent.document).show();
                    $('.validation-modal', parent.document).show();

                    args.set_cancel(true);
                }
                catch (e) { }
            }
            else {
                var masterTable = $find("<%= WorkListGrid.ClientID %>").get_masterTableView();
                masterTable.fireCommand("startpreassessment", args);
            }
        }
        function editWorklistPatient(sender, args) {
            if (document.getElementById("WorklistPatientHiddenField").value == "") {

                //create modal for window
                $('#masterValDiv', parent.document).html("No patient selected. Please select from the list and try again.");
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();

                args.set_cancel(true);
            }
            else {
                var selectedItem = $find("ctl00_BodyContentPlaceHolder_WorklistControl_WorkListGrid").get_masterTableView().get_selectedItems()[0];
                var status = selectedItem.getDataKeyValue("AppointmentStatusHDCKEY");
                if (status == "IP") {
                    alert('Procedure in progress. Cannot edit');
                }
                else {
                    var isAppointmentBooking = selectedItem.getDataKeyValue("BookingTypeId");
                    if (isAppointmentBooking == undefined || isAppointmentBooking == "2") {
                        alert('Editing Appointment Booking still to do');
                    } else {
                        var patId = document.getElementById("WorklistPatientHiddenField").value;
                        var uniqueId = selectedItem.getDataKeyValue("UniqueId");

                        var oWnd = $find("<%=EditWorklistWindow.ClientID%>");
                        oWnd._navigateUrl = "Options/AddToWorklist.aspx?PatientId=" + patId + "&UniqueId=" + uniqueId + "&mode=edit";
                        oWnd.show();
                    }
                }
            }
        }

        function removeWorklistPatient(sender, args) {
            if (document.getElementById("WorklistPatientHiddenField").value == "") {

                //create modal for window
                $('#masterValDiv', parent.document).html("No patient selected. Please select from the list and try again.");
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();

                args.set_cancel(true);
            }
            else {
                var selectedItem = $find("ctl00_BodyContentPlaceHolder_WorklistControl_WorkListGrid").get_masterTableView().get_selectedItems()[0];
                var status = selectedItem.getDataKeyValue("AppointmentStatusHDCKEY");
                if (status == "IP") {
                    //alert('Procedure in progress. Cannot remove');
                    $('#masterValDiv', parent.document).html("Procedure in progress. Cannot remove.");
                    $('#ValidationNotification', parent.document).show();
                    $('.validation-modal', parent.document).show();

                    args.set_cancel(true);
                }
                else {
                    if (confirm("Are you sure you want to remove this patient from the worklist?")) {
                        var masterTable = $find("<%= WorkListGrid.ClientID %>").get_masterTableView();
                        masterTable.fireCommand("remove", "");
                    }
                    else {
                        args.set_cancel(true);
                    }
                }
            }
        }

        function goToPatient(sender, args) {
            var masterTable = $find("<%= WorkListGrid.ClientID %>").get_masterTableView();
            masterTable.fireCommand("goToPatient", "");
        }

        function goToScheduler(sender, args) {
            var masterTable = $find("<%= WorkListGrid.ClientID %>").get_masterTableView();
            masterTable.fireCommand("goToScheduler", "");
        }

        function showContextMenuWrk(sender, eventArgs) {           
            $find('<%= WorkListGrid.ClientID %>').clearSelectedItems();
            var menu = $telerik.findControl(document, "RadMenu2");
            var evt = eventArgs.get_domEvent();
            if (evt.target.tagName == "INPUT" || evt.target.tagName == "A") {
                return;
            }

            var rowIndex = eventArgs.get_itemIndexHierarchical();
            var row = $find('<%= WorkListGrid.ClientID %>').get_masterTableView().get_dataItems()[rowIndex];
            row.set_selected(true);

            document.getElementById("WorklistPatientHiddenField").value = row.getDataKeyValue("PatientId");
            document.getElementById("WorklistSelectedIdHiddenField").value = row.getDataKeyValue("UniqueId");
            document.getElementById("WorklistProcedureIdHiddenField").value = row.getDataKeyValue("ProcedureTypeId");

            var status = row.getDataKeyValue("AppointmentStatusHDCKEY");

            var bookingTypeId = row.getDataKeyValue("BookingTypeId");
            if (bookingTypeId == undefined || bookingTypeId == "2") {
                menu.findItemByText("Edit").hide();
                //menu.findItemByText("Remove").hide();
            } else {
                if (status == "IP") {
                    menu.findItemByText("Edit").hide();
                    //menu.findItemByText("Remove").hide();
                } else {
                    menu.findItemByText("Edit").hide();
                    //menu.findItemByText("Remove").show();
                }
            }

            var roomId = row.getDataKeyValue("RoomId");
            if (roomId == undefined || roomId == '') {
                menu.findItemByValue("goToScheduler").disable();
            } else {
                menu.findItemByValue("goToScheduler").enable();
            }
            switch (status) {
                case "":
                case "B":
                    menu.findItemByValue("B").disable();
                    menu.findItemByValue("BA").enable();
                    menu.findItemByValue("DC").enable();
                    menu.findItemByValue("D").enable();
                    menu.findItemByValue("X").enable();
                    //menu.findItemByValue("C").enable();
                    menu.findItemByValue("Start").enable();
                    menu.findItemByValue("GoToPatient").enable();
                    break;
                case "BA":
                    menu.findItemByValue("B").enable();
                    menu.findItemByValue("BA").disable();
                    menu.findItemByValue("DC").enable();
                    menu.findItemByValue("D").enable();
                    menu.findItemByValue("X").enable();
                    //menu.findItemByValue("C").enable();
                    menu.findItemByValue("Start").enable();
                    menu.findItemByValue("GoToPatient").enable();
                    break;
                case "DC":
                    menu.findItemByValue("B").disable();
                    menu.findItemByValue("BA").disable();
                    menu.findItemByValue("DC").disable();
                    menu.findItemByValue("D").disable();
                    menu.findItemByValue("X").disable();
                    //menu.findItemByValue("C").disable();
                    menu.findItemByValue("Start").enable();
                    menu.findItemByValue("GoToPatient").enable();
                    break;
                case "D":
                    menu.findItemByValue("B").enable();
                    menu.findItemByValue("BA").enable();
                    menu.findItemByValue("DC").enable();
                    menu.findItemByValue("D").disable();
                    menu.findItemByValue("X").enable();
                    //menu.findItemByValue("C").enable();
                    menu.findItemByValue("Start").enable();
                    menu.findItemByValue("GoToPatient").enable();
                    break;
                case "X":
                    menu.findItemByValue("B").enable();
                    menu.findItemByValue("BA").enable();
                    menu.findItemByValue("DC").enable();
                    menu.findItemByValue("D").enable();
                    menu.findItemByValue("X").disable();
                    //menu.findItemByValue("C").enable();
                    menu.findItemByValue("Start").enable();
                    menu.findItemByValue("GoToPatient").enable();
                    break;
                case "C":
                    menu.findItemByValue("B").disable();
                    menu.findItemByValue("BA").disable();
                    menu.findItemByValue("DC").disable();
                    menu.findItemByValue("D").disable();
                    menu.findItemByValue("X").disable();
                    //menu.findItemByValue("C").disable();
                    menu.findItemByValue("Start").disable();
                    menu.findItemByValue("GoToPatient").disable();
                    break;
                case "IP":
                    menu.findItemByValue("B").enable();
                    menu.findItemByValue("BA").enable();
                    menu.findItemByValue("DC").enable();
                    menu.findItemByValue("D").disable();
                    menu.findItemByValue("X").disable();
                    //menu.findItemByValue("C").enable();
                    menu.findItemByValue("Start").enable();
                    menu.findItemByValue("GoToPatient").enable();
                    break; 
                case "RC": //  4406
                    menu.findItemByValue("B").disable();
                    menu.findItemByValue("BA").disable();
                    menu.findItemByValue("DC").enable();
                    menu.findItemByValue("D").disable();
                    menu.findItemByValue("X").disable();
                    menu.findItemByValue("Start").enable();
                    menu.findItemByValue("GoToPatient").enable();
                    break; //  4406
            }

            menu.show(evt);
            evt.cancelBubble = true;
            evt.returnValue = false;

            if (evt.stopPropagation) {
                evt.stopPropagation();
                evt.preventDefault();
            }
        }

        function GetRadWindow() {
            var oWindow = null;
            if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
            else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

            return oWindow;
        }

        function test(sender, eventArgs) {
            var startDate = $find("<%= StartDate.ClientID %>");
            if (startDate.get_selectedDate() == null) {
                $('#masterValDiv', parent.document).html("Please select a StartDate");
                $('#ValidationNotification', parent.document).show();
                $('.validation-modal', parent.document).show();
                //alert('Please select a StartDate');
                args.set_cancel(true);
            }
        }

        function RowDeselected(sender, eventArgs) {
            var MasterTable = sender.get_masterTableView();
            var row = eventArgs.get_gridDataItem();
            var cell = MasterTable.getCellByColumnUniqueName(row, "ArrowColumn");
            var image = cell.getElementsByTagName("IMG")[0];
            image.style.display = "none";
            row.get_element().className = row.get_element().className + ' row-colour-opacity';
        }

        function RowSelected(sender, eventArgs) {
            var MasterTable = sender.get_masterTableView();
            var row = eventArgs.get_gridDataItem();
            var cell = MasterTable.getCellByColumnUniqueName(row, "ArrowColumn");
            var image = cell.getElementsByTagName("IMG")[0];
            image.style.display = "block";
            row.get_element().className = row.get_element().className.replace('row-colour-opacity', '');
        }
    </script>
</telerik:RadCodeBlock>
