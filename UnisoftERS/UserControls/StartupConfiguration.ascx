<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="StartupConfiguration.ascx.vb" Inherits="UnisoftERS.StartupConfiguration" %>
<telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
    <script type="text/javascript">
        $(window).on('load', function () {
        });
        $(document).ready(function () {
            $("#<%=AllProcCheckBox.ClientID%>").click(function () {
                if ($("#<%=AllProcCheckBox.ClientID%>").is(':checked')) { $('#procTD input:checkbox').not($("#<%=AllProcCheckBox.ClientID%>")).prop('checked', false); }
            });
            $('#procTD input:checkbox').not($("#<%=AllProcCheckBox.ClientID%>")).click(function () {
                if ($(this).is(':checked')) {
                    if ($("#<%=AllProcCheckBox.ClientID%>").is(':checked')) { $("#<%=AllProcCheckBox.ClientID%>").prop('checked', false); }
                }
            });
        });
        function onChange(sender) {
            if ($("#<%=OptionOnlyLastRadioButton.ClientID%>").is(':checked')) {
                $find("<%=OptionOnlyLastRadNumericTextBox.ClientID%>").enable();
                $find("<%=OptionFromRadDateInput.ClientID%>").disable();
                $find("<%=OptionLastRadNumericTextBox.ClientID%>").disable();
            }
            if ($("#<%=OptionFromRadioButton.ClientID%>").is(':checked')) {
                $find("<%=OptionFromRadDateInput.ClientID%>").enable();
                $find("<%=OptionOnlyLastRadNumericTextBox.ClientID%>").disable();
                $find("<%=OptionLastRadNumericTextBox.ClientID%>").disable();
            }
            if ($("#<%=OptionLastRadioButton.ClientID%>").is(':checked')) {
                $find("<%=OptionLastRadNumericTextBox.ClientID%>").enable();
                $find("<%=OptionOnlyLastRadNumericTextBox.ClientID%>").disable();
                $find("<%=OptionFromRadDateInput.ClientID%>").disable();
            }
            if ($("#<%=OptionAllRadioButton.ClientID%>").is(':checked')) {
                $find("<%=OptionLastRadNumericTextBox.ClientID%>").disable();
                $find("<%=OptionOnlyLastRadNumericTextBox.ClientID%>").disable();
                $find("<%=OptionFromRadDateInput.ClientID%>").disable();
            }
        }
    </script>
</telerik:RadCodeBlock>

<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" />
<telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="decorationZone" Skin="Metro" />

<div id="decorationZone">
    <table id="ControlsTable" runat="server" style="margin-top: 0px; margin-left: 0px;" width="95%" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <fieldset class="sysFieldset">
                    <legend>How do you want the software to appear at start up?</legend>
                    <table>
                        <tr>
                            <td>
                                <asp:CheckBox runat="server" ID="WorklistCheckbox" Text="Begin by displaying the worklist" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox runat="server" ID="HideStartupChartsCheckBox" Text="Hide startup charts" />
                            </td>
                        </tr>
                    </table>

                </fieldset>
            </td>
        </tr>
        <tr style="display:none;">
            <td>
                <div style="width: 100%; float: left;">
                    <fieldset>
                        <legend>Search Settings</legend>
                        <table id="PatientListRadioButtonTable" runat="server">
                            <tr>
                                <td valign="top">
                                    <fieldset style="height: 210px; width: 385px">
                                        <p>
                                            <asp:RadioButton runat="server" ID="OptionAllRadioButton" Text="all the patient in the database(the default)" GroupName="plist" Checked="true" onclick="javascript:onChange(this);" />
                                        </p>
                                        <p>
                                            <asp:RadioButton runat="server" ID="OptionOnlyLastRadioButton" Text="only the last " GroupName="plist" onclick="javascript:onChange(this);" />
                                            <telerik:RadNumericTextBox ID="OptionOnlyLastRadNumericTextBox" Enabled="false" runat="server" IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="1" Width="65px"
                                                MinValue="1" Value="100" MaxLength="7">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                            <label>patients</label>
                                        </p>
                                        <p>
                                            <asp:RadioButton runat="server" ID="OptionFromRadioButton" Text="those patients added from " GroupName="plist" onclick="javascript:onChange(this);" />
                                            <telerik:RadDateInput ID="OptionFromRadDateInput" runat="server" Enabled="false" DateFormat="dd/MM/yyyy" DisplayDateFormat="dd/MM/yyyy">
                                            </telerik:RadDateInput>

                                        </p>
                                        <p>
                                            <asp:RadioButton runat="server" ID="OptionLastRadioButton" Text="those patients added in the last " GroupName="plist" onclick="javascript:onChange(this);" />
                                            <telerik:RadNumericTextBox ID="OptionLastRadNumericTextBox" Enabled="false" runat="server" IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="1" Width="35px"
                                                MinValue="0" Value="6" MaxLength="4">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                            <label>months</label>
                                        </p>
                                        <p>
                                            <asp:CheckBox runat="server" ID="DeadCheckBox" Text="Exclude patients who have died" />
                                        </p>
                                        <p>
                                            <asp:CheckBox runat="server" ID="OldProcCheckBox" Text="Exclude old procedures" />
                                        </p>
                                    </fieldset>
                                </td>
                                <td valign="top" id="procTD">
                                    <fieldset style="height: 210px; width: 250px">
                                        <p>
                                            <asp:CheckBox ID="AllProcCheckBox" runat="server" Text="All procedures" Checked="true" />
                                        </p>
                                        <p>
                                            <asp:CheckBox ID="GastroCheckBox" runat="server" Text="gastroscopy" />
                                        </p>
                                        <p>
                                            <asp:CheckBox ID="ERCPCheckBox" runat="server" Text="ERCP" />
                                        </p>
                                        <p>
                                            <asp:CheckBox ID="ColonCheckBox" runat="server" Text="colon/sigmoidoscopy" />
                                        </p>
                                        <p>
                                            <asp:CheckBox ID="ProctoCheckBox" runat="server" Text="proctoscopy" />
                                        </p>
                                        <p>
                                            <asp:CheckBox ID="CLOCheckBox" runat="server" Text="outstanding CLO test" />
                                        </p>
                                    </fieldset>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                <div style="width: 50%; float: right; display: none;">
                    <fieldset>
                        <legend>Worklist Settings</legend>
                        <table>
                            <tr>
                                <td>
                                    <p>
                                        <asp:CheckBox ID="ViewPreviousWorklistPatientsCheckBox" runat="server" Text="View Historic" />
                                    </p>
                                </td>
                            </tr>
                            <tr>
                                <td>Procedures to display:<br />
                                    <p>
                                        <asp:CheckBoxList ID="WorklistProceduresCheckboxList" runat="server" CellPadding="5" DataSourceID="ProcedureTypesDataSource" DataTextField="ProcedureType" DataValueField="ProcedureTypeId" RepeatColumns="4" AppendDataBoundItems="true">
                                            <asp:ListItem Value="0" Text="All Procedures" Selected="True" />
                                        </asp:CheckBoxList>
                                    </p>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
            </td>
        </tr>
        <tr>
            <td>
                <fieldset>
                    <legend>When the list of patients is displayed</legend>
                    <p>
                        <asp:RadioButton runat="server" ID="ReverseRadioButton" Text="show them in reverse date order (the most recently added, appearing at the top of the list)" GroupName="dlist" Checked="true" />
                    </p>
                    <p>
                        <asp:RadioButton runat="server" ID="AlphabetRadioButton" Text="show them in alphabetical order of surname" GroupName="dlist" />
                    </p>
                </fieldset>
            </td>
        </tr>
    </table>

    <div id="cmdOtherData" style="height: 10px; margin-top: 5px; margin-left: 10px; padding-top: 6px;">
        <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClick="saveData" Icon-PrimaryIconCssClass="telerikSaveButton" />
        <%--<telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20"
            AutoPostBack="false" Icon-PrimaryIconCssClass="telerikCancelButton" />--%>
    </div>
</div>

<asp:SqlDataSource ID="ProcedureTypesDataSource" runat="server" SelectCommand="SELECT ProcedureTypeId, ProcedureType FROM ERS_ProcedureTypes ORDER BY ProcedureTypeId" />
