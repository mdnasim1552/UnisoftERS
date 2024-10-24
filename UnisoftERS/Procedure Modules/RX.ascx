<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="RX.ascx.vb" Inherits="UnisoftERS.RX" %>
<style type="text/css">
    .DataBoundTable td {
        width: 33.3%;
    }

    .gi-bleeds-button {
        margin-left: 5px;
    }

    .comorb-child {
        margin-left: 10px;
        display: none;
    }

    .checkboxesTable td {
        padding-right: 10px;
        padding-bottom: 3px;
    }

    .auto-style1 {
        width: 230px;
    }
</style>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var medArr = [];
        var sVar;
        var sVar1;
        var sVar2;
        var sVar3;

        $(document).ready(function () {
            onLoad();

            //$('.rx_checkbox').on('change', function () {
            //    saveRXMedication();
            //});
            var totalAdded = 0;
            var initPosition = getLength();
            var isEnter = false;
            var formattedText = '';
            $('.rx_textbox').on('focusout', function () {
                saveRXMedication(isEnter);
                totalAdded = 0, isEnter = false, initPosition = getLength();
            });
            $('.rx_textbox').on('input', function (event) {
                var currentKey = event.originalEvent.data;

                if (initPosition !== getLength()) {
                    isEnter = true;
                }
                else
                {
                    isEnter = false;
                }
            });
            $("#<%=ContMedication.ClientID%>").click(function () {
                if ($("#<%=ContMedication.ClientID%>").is(':checked')) {
                    $("#<%= ModifyMedicationRadButton.ClientID%>").toggle(true);
                   <%-- sVar= '<%=ContinueData%>';--%>
                    //PopulateDataOnLoad(sVar);
                    //fillBox();
                } else {
                    medArr = medArr.filter(function (el) { return el.id != 1; });
                    //fillBox();
                    $("#<%= ModifyMedicationRadButton.ClientID%>").toggle(false);
                }
                saveRXMedication(isEnter);
            });
            $("#<%=ContMedicationByGP.ClientID%>").click(function () {
                if ($("#<%=ContMedicationByGP.ClientID%>").is(':checked')) {
                    $("#<%= ModifyGPMedicationRadButton.ClientID%>").toggle(true);
                   <%-- sVar1 = '<%=GPData%>';--%>
                    //PopulateDataOnLoad(sVar1);
                    //fillBox();
                } else {
                    medArr = medArr.filter(function (el) { return el.id != 3; });
                    //fillBox();
                    $("#<%= ModifyGPMedicationRadButton.ClientID%>").toggle(false);
                }
                saveRXMedication(isEnter);


            });
            $("#<%=ContPrescribeMedication.ClientID%>").click(function () {
                if ($("#<%=ContPrescribeMedication.ClientID%>").is(':checked')) {
                    $("#<%= ModifyPrescribeMedicationRadButton.ClientID%>").toggle(true);
                   <%-- sVar2 = '<%=HospitalData%>';--%>
                    //PopulateDataOnLoad(sVar2);
                    //fillBox();
                } else {
                    medArr = medArr.filter(function (el) { return el.id != 2; });
                    //fillBox();
                    $("#<%= ModifyPrescribeMedicationRadButton.ClientID%>").toggle(false);

                }
                saveRXMedication(isEnter);

            });
            $("#<%=SuggestPrescribe.ClientID%>").click(function () {
                if ($("#<%=SuggestPrescribe.ClientID%>").is(':checked')) {
                    $("#<%= ModifySuggestMedicationRadButton.ClientID%>").toggle(true);
                   <%-- sVar3 = '<%=SuggestedData%>';--%>
                    //PopulateDataOnLoad(sVar3);
                    //fillBox();
                } else {
                    medArr = medArr.filter(function (el) { return el.id != 4; });
                    //fillBox();
                    $("#<%= ModifySuggestMedicationRadButton.ClientID%>").toggle(false);

                }
                saveRXMedication(isEnter);
            });

            $("#<%=ModifyMedicationRadButton.ClientID%>").click(function () {
                var oWnd = $find("<%= PrescriptionWindow.ClientID %>");
                oWnd._navigateUrl = "<%= ResolveUrl("~/Products/Gastro/OtherData/OGD/PatientMedication.aspx?title=Modify Continued Medication&id=1")%>";
                oWnd.set_title("Continued Medication");
                oWnd.SetSize(835, 670);
                oWnd.show();
                oWnd.add_close(reloadMedication);
            });

            $("#<%=ModifyGPMedicationRadButton.ClientID%>").click(function () {
                var oWnd = $find("<%= PrescriptionWindow.ClientID %>");
                oWnd._navigateUrl = "<%= ResolveUrl("~/Products/Gastro/OtherData/OGD/PatientMedication.aspx?title=Set GP Prescribed Medication&id=3")%>";
                oWnd.set_title("Set GP Prescribed Medication");
                oWnd.SetSize(835, 670);
                oWnd.show();
                oWnd.add_close(reloadMedication);
                //initPosition = initPos();
                //oWindow.set_title("GP Prescribed Medication");
                //oWindow.set_visibleStatusbar(false);
                //oWindow.add_close(reloadMedication);
                //return false;
            });

            $("#<%=ModifyPrescribeMedicationRadButton.ClientID%>").click(function () {
                var oWnd = $find("<%= PrescriptionWindow.ClientID %>");
                oWnd._navigateUrl = "<%= ResolveUrl("~/Products/Gastro/OtherData/OGD/PatientMedication.aspx?title=Set Hospital Prescribed Medication&id=2")%>";
                oWnd.set_title("Set Hospital Prescribed Medication");
                oWnd.SetSize(835, 670);
                oWnd.show();
                oWnd.add_close(reloadMedication);

                //var oWindow = radopen("../Products/Gastro/OtherData/OGD/PatientMedication.aspx?title=Set Hospital Prescribed Medication&id=2", "ContinueMedication3", '835px', '670px');
                //oWindow.set_title("Hospital Prescribed Medication");
                //oWindow.set_visibleStatusbar(false);
                //oWindow.add_close(reloadMedication);
                //return false;
            });

            $("#<%=ModifySuggestMedicationRadButton.ClientID%>").click(function () {
                var oWnd = $find("<%= PrescriptionWindow.ClientID %>");
                oWnd._navigateUrl = "<%= ResolveUrl("~/Products/Gastro/OtherData/OGD/PatientMedication.aspx?title=Set Suggest Medication&id=4")%>";
                oWnd.set_title("Set Suggest Medication");
                oWnd.SetSize(835, 670);
                oWnd.show();
                oWnd.add_close(reloadMedication);

                //var oWindow = radopen("../Products/Gastro/OtherData/OGD/PatientMedication.aspx?title=Set Suggest Medication&id=4", "ContinueMedication4", '835px', '670px');
                //oWindow.set_title("Suggest Medication");
                //oWindow.set_visibleStatusbar(false);
                //oWindow.add_close(reloadMedication);
                //return false;
            });
        });
        function getLength() {
            var text = $('#<%=MedicationText.ClientID%>').val();

            return text.length;
        }
        function reloadMedication() {
            //ajax call to get the value
            var obj = {};
            obj.procID = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);

            $.ajax({
                type: "POST",
                url: "PostProcedure.aspx/loadRXPrescription",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    var txtdesc = $find("<%= MedicationText.ClientID%>");
                    txtdesc.set_value(data.d);
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    <%--$find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();--%>
                }
            });
        }

        function fillBox() {
            if ($("#<%=ContMedication.ClientID%>").is(':checked') == false) { medArr = medArr.filter(function (el) { return el.id != 1; }); }
            if ($("#<%=ContMedicationByGP.ClientID%>").is(':checked') == false) { medArr = medArr.filter(function (el) { return el.id != 3; }); }
            if ($("#<%=ContPrescribeMedication.ClientID%>").is(':checked') == false) { medArr = medArr.filter(function (el) { return el.id != 2; }); }
            if ($("#<%=SuggestPrescribe.ClientID%>").is(':checked') == false) { medArr = medArr.filter(function (el) { return el.id != 4; }); }
            medArr.sort(function (a, b) { return parseFloat(a.id) - parseFloat(b.id); });
            if (medArr.length > 0) {
                var msg = "";
                medArr = medArr.filter(function (el) { return el.id != ""; });
                for (x in medArr) {
                    if (medArr[x].text != undefined) {
                        msg += medArr[x].text.trim() + ". ";
                    }
                }
                var txtdesc = $find("<%= MedicationText.ClientID%>");
                txtdesc.set_value(msg.trim());
            } else {
                var txtdesc = $find("<%= MedicationText.ClientID%>");
                txtdesc.set_value('');
            }

            //saveRXMedication();
        }

        function onLoad() {
            //reads variables from code behind and use it to intialise slected boxes
            sVar = '<%=ContinueData%>';
            PopulateDataOnLoad(sVar);
            sVar1 = '<%=GPData%>';
            PopulateDataOnLoad(sVar1);
            sVar2 = '<%=HospitalData%>';
            PopulateDataOnLoad(sVar2);
            sVar3 = '<%=SuggestedData%>';
            PopulateDataOnLoad(sVar3);
        }

        function PopulateDataOnLoad(data) {
            var partsOfStr = data.split('#');
            //replace medication if already exist
            var obj = medArr.filter(function (obj) {
                return obj.id === partsOfStr[0];
            })[0];

            if (obj != null) {
                obj.text = partsOfStr[1];
            } else {
                medArr.push({ id: partsOfStr[0], text: partsOfStr[1] });
            }
        }

        function CalledRXFn(data) {
            var partsOfStr = data.split('#');
            if (partsOfStr[0] == '1') { sVar = data; }
            if (partsOfStr[0] == '2') { sVar2 = data; }
            if (partsOfStr[0] == '3') { sVar1 = data; }
            if (partsOfStr[0] == '4') { sVar3 = data; }

            //replace medication if already exist
            var obj = medArr.filter(function (obj) {
                return obj.id === partsOfStr[0];
            })[0];

            if (obj != null) {
                obj.text = partsOfStr[1];
            } else {
                medArr.push({ id: partsOfStr[0], text: partsOfStr[1] });
            }
            fillBox();

        }

        function saveRXMedication(isModified) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.continueMedication = $('#<%=ContMedication.ClientID%>').is(':checked');
            obj.continueGPPrescription = $('#<%=ContMedicationByGP.ClientID%>').is(':checked');
            obj.continueHospitalSubscription = $('#<%=ContPrescribeMedication.ClientID%>').is(':checked');
            obj.suggestedMedication = $('#<%=SuggestPrescribe.ClientID%>').is(':checked');
            obj.medicationText = $('#<%=MedicationText.ClientID%>').val();
            obj.isModified = isModified;
            
                $.ajax({
                    type: "POST",
                    url: "PostProcedure.aspx/saveRXMedication",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        setRehideSummary();
                        var txtdesc = $find("<%= MedicationText.ClientID%>");
                        txtdesc.set_value(data.d);
                    },
                    error: function (x, y, z) {
                        autoSaveSuccess = false;
                        //show a message
                        var objError = x.responseJSON;
                        var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                        $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                        $find('<%=RadNotification1.ClientID%>').show();
                    }
                });



        }
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />


<div class="control-content">
    <div style="margin-top: 10px; margin-bottom: 20px;">
        <fieldset id="DocumentationFieldset" runat="server" class="otherDataFieldset" style="width: 700px;">
            <legend>Hint</legend>
            You can edit the text in red. But only do so after the medication has been set via the boxes and buttons. 
                            If you edit the text then try and change the medication you will be advised that the original edits will be lost.
        </fieldset>
    </div>

    <div style="margin: 20px 0px 0px 0px; padding: 0px 10px 0px 0px;">
        <table id="table1" runat="server" cellspacing="10" cellpadding="0" border="0" style="margin: 5px; padding-bottom: 5px;">
            <tr>
                <td class="auto-style1" style="width: 400px;">
                    <asp:CheckBox ID="ContMedication" runat="server" Text="Continue existing medication" AutoPostBack="false" CssClass="rx_checkbox" />
                </td>
                <td class="auto-style1">
                    <telerik:RadButton ID="ModifyMedicationRadButton" runat="server" Text="Set / Modify Medication" Skin="Metro" Style="display: none" AutoPostBack="false" Width="190" />
                </td>

                <td></td>
            </tr>
            <tr>
                <td class="auto-style1">
                    <asp:CheckBox ID="ContMedicationByGP" runat="server" Text="Medication to be prescribed by GP" AutoPostBack="false" CssClass="rx_checkbox" /></td>
                <td>
                    <telerik:RadButton ID="ModifyGPMedicationRadButton" runat="server" Text="Set / Modify Medication" Skin="Metro" Style="display: none" AutoPostBack="false" Width="190" />
                </td>

                <td></td>
            </tr>
            <tr>
                <td class="auto-style1">
                    <asp:CheckBox ID="ContPrescribeMedication" runat="server" Text="Medication to be prescribed by hospital" AutoPostBack="false" CssClass="rx_checkbox" /></td>
                <td>
                    <telerik:RadButton ID="ModifyPrescribeMedicationRadButton" runat="server" Text="Set / Modify Medication" Skin="Metro" Style="display: none" AutoPostBack="false" Width="190" />
                </td>

                <td></td>
            </tr>
            <tr>
                <td class="auto-style1">
                    <asp:CheckBox ID="SuggestPrescribe" runat="server" Text="Suggest medication" AutoPostBack="false" CssClass="rx_checkbox" /></td>
                <td>
                    <telerik:RadButton ID="ModifySuggestMedicationRadButton" runat="server" Text="Set / Modify Medication" Skin="Metro" Style="display: none" AutoPostBack="false" Width="190" />
                </td>

                <td></td>
            </tr>
            <tr>
                <td colspan="4" style="height: 7px;"></td>
            </tr>
            <tr>
                <td colspan="4">&nbsp;<telerik:RadTextBox ID="MedicationText" runat="server" Skin="Office2007" TextMode="MultiLine" Height="96"  Width="1000" AutoPostBack="false" CssClass="rx_textbox"    /></td>
              
            </tr>
            
            
        </table>
    </div>
</div>
<telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" OnClientClose="OnClientClose"
    Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" Modal="True" Behavior="Close, Move" ReloadOnShow="True" VisibleStatusbar="false">
    <Windows>
        <telerik:RadWindow ID="PrescriptionWindow" runat="server" />
    </Windows>
</telerik:RadWindowManager>
