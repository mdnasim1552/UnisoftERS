<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PostProcedualData.aspx.vb" Inherits="UnisoftERS.PostProcedualData" %>

<%@ Register Src="~/Procedure Modules/DiscomfortScore.ascx" TagPrefix="uc1" TagName="DiscomfortScore" %>
<%@ Register Src="~/Procedure Modules/SedationScore.ascx" TagPrefix="uc1" TagName="SedationScore" %>



<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" Visible="False" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        body {
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            font-size: 12px;
            height: auto;
        }

        .path-results-tab-table {
            width: 100%;
        }

        .focal-post-op-complications tr[data-for-procedure] {
            padding: 5px 0px;
            display: none;
        }
        /* Added by rony tfs-1861 */
        .scope-damage-position{
            float: left;
            padding:1px;
        }
    </style>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">

            $(document).ready(
                function () {
                    $('#<%=PostPEGInfectionCheckBox.ClientID%>').click(function () {
                        if (!this.checked) {
                            $('#<%=PostPEGInfectionAntibioticsCheckBox.ClientID%>').prop('checked', false);
                        }
                    });
                    <%--var ScopeDiscoveredComboBox = $find('<%=ScopeDiscoveredComboBox.ClientID %>')
                    if (ScopeDiscoveredComboBox != null) {
                        toggleScopeDiscoveredOther();//Added by rony tfs-1861
                    }--%>     
                    checkScopeDamageCheckbox();
                }
            );

            /*Patient Comfort Levels Functions*/
          <%--  function TogglePatSedationComboBox() {
                var valu = $('#<%=PatSedationRadioButtonList.ClientID%> input[type=radio]:checked').val();
                if (valu == '4') {
                    $("#<%= PatSedationAsleepResponseStateComboBox.ClientID%>").show();
                }
                else {
                    $("#<%= PatSedationAsleepResponseStateComboBox.ClientID%>").hide();
                    $('#<%= PatSedationAsleepResponseStateComboBox.ClientID%>').val("");
                }
            }--%>

            /*Post-operative complications Functions */
            function showPostOpComplications() {
                var selectedProcType = <%=ProcType%>
                var selectedProcId = <%=ProcedureID%>

                toggleSeverity();
                toggleDOD();
                toggleReadmission();
                
                //ajax call to determine whether to show PEG detailsx
                $.ajax({
                    type: "POST",
                    url: "PostProcedualData.aspx/IsPEG",
                    data: JSON.stringify({ "procedureId": parseInt(selectedProcId) }),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        if (data.d) {
                            $('.peg-outcomes input').on('click', function () {
                                togglePEGOutcomes();
                            });

                            $('#<%=PEGOutComesFieldset.ClientID%>').show();
                            togglePEGOutcomes();
                        }
                        else {
                            $('#<%=PEGOutComesFieldset.ClientID%>').hide();
                        }
                    },
                    error: function (jqXHR, textStatus, data) {
                        console.log(jqXHR.responseText);
                    }
                });


                $('.post-op-checkbox input:checkbox').each(function (key, value) {
                    toggleSeverityHideShow($(this));
                });

                /* event handlers */
                $('.post-op-checkbox input:checkbox').on('click', function () {
                    toggleSeverityHideShow($(this));
                });

                $('.post-op-severity').on('change', function (sender, args) {
                    toggleSeverity($(this));
                });

                $('#<%=PostOpComplicationResolutionRadioButtonList.ClientID%>').on('change', function () {
                    toggleDOD();
                });

                $('#<%=PostOpComplicationReadmissionRadioButtonList.ClientID%>').on('change', function () {
                    toggleReadmission();
                });

                if (selectedProcType == 1 || selectedProcType == 6) {
                    //hide all data-for-procedure TR's where not OGD (pipe dilimited, make sure you seperate)
                    $('.focal-post-op-complications tr[data-for-procedure*="OGD"]').each(function (key, value) {
                        $(value).show();
                    });
                }
                else if (selectedProcType == 3 || selectedProcType == 4 || selectedProcType == 5) {
                    //hide all data-for-procedure TR's where not COLON (pipe dilimited, make sure you seperate)
                    $('.focal-post-op-complications tr[data-for-procedure*="COLON"]').each(function (key, value) {
                        $(value).show();
                    });
                }
                else if (selectedProcType == 2 || selectedProcType == 7) {
                    //hide all data-for-procedure TR's where not ERCP (pipe dilimited, make sure you seperate)
                    $('.focal-post-op-complications tr[data-for-procedure*="ERCP"]').each(function (key, value) {
                        $(value).show();
                    });
                }
            }

            function togglePEGOutcomes() {
                $('.peg-outcomes .post-peg-data input').each(function (key, value) {
                    var childCB = $(this).closest('td').next().find('.hidden-cb');

                    if ($(this).is(':checked')) {
                        childCB.show();
                    }
                    else {
                        childCB.hide();
                    }
                });
            }

            function toggleSeverityHideShow(chkBox) {
                if ($(chkBox).prop("checked")) {
                    $(chkBox).closest("td").next().find(".post-op-severity").show();
                }
                else {
                    $(chkBox).closest("td").next().find(".post-op-severity").hide();
                }
            }

            function toggleSeverity(ddl) {
                if ($(ddl).val() == "4. fatal - specify date of death") {
                    //select 'death' radio button
                    $("#<%=PostOpComplicationResolutionRadioButtonList.ClientID%>").find("input[value='4']").prop("checked", true);
                    $('#<%=PostOpComplicationDodDateInput.ClientID%>').show();
                    toggleDOD();
                };
            }

            function toggleDOD() {
                if ($("#<%=PostOpComplicationResolutionRadioButtonList.ClientID%>").find("input[value='4']").is(":checked")) {
                    $("#<%=PostOpComplicationResolutionRadioButtonList.ClientID%>").closest('div').next().find('.date-picker-div').show();
                }
                else {
                    $("#<%=PostOpComplicationResolutionRadioButtonList.ClientID%>").closest('div').next().find('.date-picker-div').hide();
                }
            }

            function toggleReadmission() {
                if ($("#<%=PostOpComplicationReadmissionRadioButtonList.ClientID%>").find("input[value='1']").is(":checked")) {
                    $(".readmission-details").show();
                }
                else {
                    $(".readmission-details").hide();
                }
            }

            function CloseWindow() {
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null; if (window.radWindow)
                    oWindow = window.radWindow; else if (window.frameElement.radWindow)
                    oWindow = window.frameElement.radWindow; return oWindow;
            }
            //Added by rony tfs-1861
            function ScopeDiscoveredComboBoxChanged(sender, args) {
                if (sender.get_selectedItem().get_value() == "3") {
                    $('.other-scope-discovered-input').show();
                }
                else {
                    $('.other-scope-discovered-input').hide();
                    $('#<%=ScopeDiscoveredOtherTextBox.ClientID%>').val("");
                }
            }
            function toggleScopeDiscoveredOther() {
                var scopeDiscoveredId = $find('<%=ScopeDiscoveredComboBox.ClientID %>').get_selectedItem().get_value();
                if (scopeDiscoveredId == "3") {
                    $('.other-scope-discovered-input').show();
                }
                else {
                    $('.other-scope-discovered-input').hide();
                }
            }

            function toggleScopeDamage(checkbox) {
               var row = document.getElementById('scopeDamageRow');
                if (checkbox.checked) {
                    row.style.display = '';
                    $('.other-scope-discovered-input').show();
                }
                else {
                    row.style.display = 'none';
                    $('.other-scope-discovered-input').hide();
                }
            }
            function checkScopeDamageCheckbox() {
                var checkbox = document.getElementById('<%= ScopeDamagedCheckBox.ClientID %>');
                var row = document.getElementById('scopeDamageRow');
                 if (checkbox.checked) {
                     row.style.display = '';
                     $('.other-scope-discovered-input').show();
                 } else {
                     row.style.display = 'none';
                     $('.other-scope-discovered-input').hide();
                 }
             }
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Metro" />
        <div id="ContentDiv">
            <telerik:RadScriptManager runat="server"></telerik:RadScriptManager>
            <asp:Panel ID="UreaseResultsPanel" runat="server" Visible="false">
                <fieldset>
                    <legend>Urease Results</legend>
                    <table style="width: 100%; text-align: center;">
                        <tr>
                            <td>
                                <div id="UreaseResultsDiv" runat="server" visible="false">
                                    <div>
                                        <asp:RadioButtonList ID="UreaseResultRadioButtonList" runat="server" RepeatDirection="Horizontal" Style="margin-left: 150px;">
                                            <asp:ListItem Value="1">Positive</asp:ListItem>
                                            <asp:ListItem Value="2">Negative</asp:ListItem>
                                        </asp:RadioButtonList><br />
                                        <asp:CheckBox ID="AddToOutstandingCheckBox" runat="server" Text="Add to list of outstanding reports?" TextAlign="Right" />
                                    </div>
                                    <div style="height: auto; text-align: center; padding-top: 10px; padding-bottom: 10px;">
                                        <telerik:RadButton ID="SaveUreaseResultsButton" runat="server" Text="Save" Skin="Metro" OnClick="SaveUreaseResultsButton_Click" Icon-PrimaryIconCssClass="telerikSaveButton" />
                                        <telerik:RadButton ID="CancelSaveUreaseResultsButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" Icon-PrimaryIconCssClass="telerikCancelButton" OnClientClicked="CloseWindow" />
                                    </div>
                                </div>
                                <div id="NoResultsDiv" runat="server" visible="true" style="height: auto; text-align: center;">
                                    <p>
                                        No urease test indicated for this procedure
                                    </p>
                                    <telerik:RadButton ID="CloseUreaseResultsButton" runat="server" Text="OK" Skin="Metro" AutoPostBack="false" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikOkButton" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </asp:Panel>
            <asp:Panel ID="PostOpComplicationsPanel" runat="server" Visible="false">
                <div id="PostOpComplicationsDiv" runat="server" style="width: 700px;">
                    <fieldset>
                        <legend>Non-Specific</legend>
                        <table>
                            <tr>
                                <td>
                                    <asp:CheckBox ID="AspirationCheckBox" runat="server" Text="Aspiration/chest infection" /></td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:CheckBox ID="ArrythmiaCheckBox" runat="server" Text="Arrhythmia" /></td>
                            </tr>
                        </table>
                    </fieldset>
                    <asp:SqlDataSource ID="PostOpResolutionSQLDataSource" runat="server" SelectCommand="SELECT [ListItemText], [ListItemNo]  FROM [ERS_Lists] WHERE ( [ListDescription] ='Post Operative Complication Resolution') ORDER BY ListItemNo" />
                    <asp:SqlDataSource ID="EndoscopistSQLDataSource" runat="server" SelectCommand="SELECT [ConsultantID], [EndoName]  FROM [dbo].[tvfProcedureConsultantRoles] (@ProcedureID)">
                        <SelectParameters>
                            <asp:Parameter Name="ProcedureID" Type="Int32" />
                        </SelectParameters>
                    </asp:SqlDataSource>
                    <asp:SqlDataSource ID="PostOpSeveritySQLDataSource" runat="server" SelectCommand="SELECT [ListItemText], [ListItemNo]  FROM [ERS_Lists] WHERE ( [ListDescription] ='Post Operative Complication Severity') ORDER BY ListItemNo" />
                    <fieldset>
                        <legend>Focal</legend>
                        <table class="focal-post-op-complications">
                            <tr>
                                <td></td>
                                <td>
                                    <label class="focal-severity-label">Severity</label></td>
                            </tr>
                            <tr data-for-procedure="OGD">
                                <td>
                                    <asp:CheckBox ID="OesophagealPerforationCheckBox" CssClass="post-op-checkbox" runat="server" Text="Oesophageal perforation" /></td>
                                <td style="width: 410px;">
                                    <telerik:RadComboBox ID="OesophagealServerityComboBox" CssClass="post-op-severity" runat="server" Style="z-index: 9999; width: 400px;" DataSourceID="PostOpSeveritySQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                </td>
                            </tr>
                            <tr data-for-procedure="OGD">
                                <td>
                                    <asp:CheckBox ID="GastricPerforationCheckbox" CssClass="post-op-checkbox" runat="server" Text="Gastric perforation" /></td>
                                <td style="width: 410px;">
                                    <telerik:RadComboBox ID="GastricSeverityComboBox" CssClass="post-op-severity" runat="server" Style="z-index: 9999; width: 400px;" DataSourceID="PostOpSeveritySQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                </td>
                            </tr>
                            <tr data-for-procedure="OGD">
                                <td>
                                    <asp:CheckBox ID="BleedingFollowingPolypectomyCheckBox" CssClass="post-op-checkbox" runat="server" Text="Bleeding following polypectomy" /></td>
                                <td style="width: 410px;">
                                    <telerik:RadComboBox ID="BleedingFollowingPolypectomySeverityComboBox" CssClass="post-op-severity" runat="server" Style="z-index: 9999; width: 400px;" DataSourceID="PostOpSeveritySQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                </td>
                            </tr>
                            <tr data-for-procedure="OGD">
                                <td>
                                    <asp:CheckBox ID="MajorBleedingFollowingInjectionCheckBox" CssClass="post-op-checkbox" runat="server" Text="Major bleeding following variceal Injection" /></td>
                                <td style="width: 410px;">
                                    <telerik:RadComboBox ID="MajorBleedingFollowingInjectionSeverityComboBox" CssClass="post-op-severity" runat="server" Style="z-index: 9999; width: 400px;" DataSourceID="PostOpSeveritySQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                </td>
                            </tr>
                            <tr data-for-procedure="OGD">
                                <td>
                                    <asp:CheckBox ID="MajorUlcerationFollowingInjectionCheckBox" CssClass="post-op-checkbox" runat="server" Text="Major ulceration and stricturing following variceal injection" /></td>
                                <td style="width: 410px;">
                                    <telerik:RadComboBox ID="MajorUlcerationFollowingInjectionSeverityComboBox" CssClass="post-op-severity" runat="server" Style="z-index: 9999; width: 400px;" DataSourceID="PostOpSeveritySQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                </td>
                            </tr>
                            <tr data-for-procedure="OGD">
                                <td>
                                    <asp:CheckBox ID="HaemostasisCheckBox" CssClass="post-op-checkbox" runat="server" Text="Haemostasis following procedure" /></td>
                                <td style="width: 410px;">
                                    <telerik:RadComboBox ID="HaemostasisComboBox" CssClass="post-op-severity" runat="server" Style="z-index: 9999; width: 400px;" DataSourceID="PostOpSeveritySQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                </td>
                            </tr>

                            <tr data-for-procedure="ERCP">
                                <td>
                                    <asp:CheckBox ID="PancreatitsCheckBox" runat="server" CssClass="post-op-checkbox" Text="Pancreatitis" /></td>
                                <td style="width: 410px;">
                                    <telerik:RadComboBox ID="PancreatitsSeverityComboBox" CssClass="post-op-severity" runat="server" Style="z-index: 9999; width: 400px;" DataSourceID="PostOpSeveritySQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                </td>
                            </tr>
                            <tr data-for-procedure="ERCP">
                                <td>
                                    <asp:CheckBox ID="AscendingCholangitisCheckBox" CssClass="post-op-checkbox" runat="server" Text="Ascending cholangitis" /></td>
                                <td style="width: 410px;">
                                    <telerik:RadComboBox ID="AscendingCholangitisSeverityComboBox" CssClass="post-op-severity" runat="server" Style="z-index: 9999; width: 400px;" DataSourceID="PostOpSeveritySQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                </td>
                            </tr>
                            <tr data-for-procedure="ERCP|COLON">
                                <td>
                                    <asp:CheckBox ID="PerforationCheckBox" CssClass="post-op-checkbox" runat="server" Text="Perforation" /></td>
                                <td style="width: 410px;">
                                    <telerik:RadComboBox ID="PerforationSeverityComboBox" CssClass="post-op-severity" runat="server" Style="z-index: 9999; width: 400px;" DataSourceID="PostOpSeveritySQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                </td>
                            </tr>
                            <tr data-for-procedure="ERCP|COLON">
                                <td>
                                    <asp:CheckBox ID="HaemorrhageCheckBox" CssClass="post-op-checkbox" runat="server" Text="Haemorrhage" SkinID="Metro" /></td>
                                <td style="width: 410px;">
                                    <telerik:RadComboBox ID="HaemorrhageSeverityComboBox" CssClass="post-op-severity" runat="server" Style="z-index: 9999; width: 400px;" DataSourceID="PostOpSeveritySQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-left: 20px;">Other:</td>
                                <td style="width: 410px;">
                                    <telerik:RadTextBox ID="OGDOtherFocalTextBox" runat="server" Width="100%" />
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                    <fieldset id="PEGOutComesFieldset" runat="server" style="display: none;">
                        <legend>PEG Outcomes</legend>
                        <table class="peg-outcomes">
                            <tr>
                                <td>
                                    <asp:CheckBox ID="PostPEGInfectionCheckBox" runat="server" Text="Infection" CssClass="post-peg-data" />&nbsp;
                                </td>
                                <td>
                                    <asp:CheckBox ID="PostPEGInfectionAntibioticsCheckBox" runat="server" Text="Requires antibiotics?" CssClass="hidden-cb" Style="display: none;" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:CheckBox ID="PostPEGPeritonitisCheckBox" runat="server" Text="Peritonitis" />&nbsp;
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                    <fieldset>
                        <legend>Resolution</legend>
                        <table>
                            <tr>
                                <td>
                                    <div style="float: left;">
                                        <asp:RadioButtonList ID="PostOpComplicationResolutionRadioButtonList" runat="server" RepeatDirection="Horizontal" DataSourceID="PostOpResolutionSQLDataSource" DataTextField="ListItemText" DataValueField="ListItemNo" />
                                    </div>
                                    <div style="float: left; padding-top: 5px; padding-left: 5px;">
                                        <div class="date-picker-div">
                                            <telerik:RadDatePicker ID="PostOpComplicationDodDateInput" Style="z-index: 9999;" runat="server" Width="100px" Skin="Metro" Culture="en-GB" DateInput-DateFormat="dd/MM/yyyy" DateInput-DisplayDateFormat="dd/MM/yyyy" />
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                    <fieldset>
                        <legend>Readmission</legend>
                        <table>
                            <tr>
                                <td>
                                    <div style="float: left; padding-top: 5px;">
                                        Unplanned admissions within 8 days of Endoscopy procedure?
                                    </div>
                                    <div style="float: left;">
                                        <asp:RadioButtonList ID="PostOpComplicationReadmissionRadioButtonList" runat="server" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="0" Selected="True">No</asp:ListItem>
                                            <asp:ListItem Value="1">Yes</asp:ListItem>
                                        </asp:RadioButtonList>
                                    </div>
                                </td>
                                <td>
                                    <div class="readmission-details" style="padding-left: 0px; padding-top: 5px;">
                                        date:&nbsp;<telerik:RadDatePicker ID="ReadmissionDateDateInput" Style="z-index: 99999999999;" runat="server" Width="100px" Skin="Metro" Culture="en-GB" DateInput-DateFormat="dd/MM/yyyy" DateInput-DisplayDateFormat="dd/MM/yyyy" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <div class="readmission-details">
                                        Reason for readmission:<br />
                                        <telerik:RadTextBox ID="ReadmissionReasonRadTextBox" runat="server" TextMode="MultiLine" Width="100%" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                    <%--Added by rony tfs-1861 start--%>
                        <fieldset>
                            <legend>Scope Damage</legend>
                            <table style="width: 100%;">
                                <tr>
                                    <td>
                                        <div class="scope-damage-position">
                                            Scope was damaged
                                        </div>
                                        <div class="scope-damage-position">
                                            <asp:CheckBox ID="ScopeDamagedCheckBox" OnClick="toggleScopeDamage(this);" runat="server" />
                                        </div>
                                    </td>
                                </tr>
                               <tr id="scopeDamageRow" style="display:none;">
                                    <td>
                                        <div class="scope-damage-position">
                                            When was this discovered?
                                        </div>
                                        <div class="scope-damage-position">
                                            <telerik:RadComboBox ID="ScopeDiscoveredComboBox" runat="server"> 
                                               <Items>  
                                                    <telerik:RadComboBoxItem Value="0" Text="Procedure room" /> 
                                                    <telerik:RadComboBoxItem Value="1" Text="Decontamination unit" /> 
                                                    <%--<telerik:RadComboBoxItem Value="3" Text="Other" /> --%> 
                                               </Items> 
                                             </telerik:RadComboBox> 
                                        </div>
                                    </td>                                    
                                </tr>
                                <tr>
                                    <td colspan="3" style="display: none;" class="other-scope-discovered-input">Comments:<br />
                                        <telerik:RadTextBox ID="ScopeDiscoveredOtherTextBox" runat="server" TextMode="MultiLine" Width="100%" />
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                        <%--End--%>
                    <fieldset>
                        <legend>Recorded by?</legend>
                        <table style="width: 100%;">
                            <tr>
                                <td>Recorded by:</td>
                                <td>
                                    <telerik:RadComboBox ID="PostOpComplicationRecordedByComboBox" runat="server" Style="z-index: 9999;" />
                                </td>
                                <td>
                                    <div class="date-picker-div">
                                        <telerik:RadDatePicker ID="PostOpComplicationDateRecordedDateInput" Style="z-index: 99999999999;" runat="server" Width="100px" Skin="Metro" Culture="en-GB" DateInput-DateFormat="dd/MM/yyyy" DateInput-DisplayDateFormat="dd/MM/yyyy" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3">Other Comments:<br />
                                    <telerik:RadTextBox ID="PostOpComplicationOtherCommentsTextBox" runat="server" TextMode="MultiLine" Width="100%" />
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                <div style="height: auto; text-align: center; padding-top: 10px;">
                    <telerik:RadButton ID="SavePostOpComplicationsRadButton" runat="server" Text="Save" Skin="Metro" OnClick="SavePostOpComplicationsRadButton_Click" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelSavePostOpComplicationsRadButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </asp:Panel>
            <asp:Panel ID="PatientComfortLevelPanel" runat="server" Visible="false">
                <table style="width: 480px;">
                    <tr>
                        <td>
                            <fieldset>
                                <legend>Assessment of</legend>
                               <%-- <asp:Label runat="server">Patient Sedation:</asp:Label>
                                <table style="margin-bottom: 10px;">
                                    <tr>
                                        <td>
                                            <asp:RadioButtonList ID="PatSedationRadioButtonList" runat="server" Enabled="false" CellSpacing="1" CellPadding="1" RepeatDirection="Horizontal" RepeatLayout="Table" onchange="TogglePatSedationComboBox();">
                                                <asp:ListItem Value="2" Text="Awake" />
                                                <asp:ListItem Value="3" Text="Drowsy" />
                                                <asp:ListItem Value="4" Text="Asleep but" />
                                            </asp:RadioButtonList>
                                        </td>
                                        <td valign="bottom">
                                            <div style="float: left">
                                                <telerik:RadComboBox ID="PatSedationAsleepResponseStateComboBox" runat="server" Enabled="false" Skin="Metro" Width="150px">
                                                    <Items>
                                                        <telerik:RadComboBoxItem Value="0" Text="" />
                                                        <telerik:RadComboBoxItem Value="1" Text="responding to name" />
                                                        <telerik:RadComboBoxItem Value="2" Text="responding to touch" />
                                                        <telerik:RadComboBoxItem Value="3" Text="unresponsive" />
                                                    </Items>
                                                </telerik:RadComboBox>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                                <asp:Label runat="server">Patient Discomfort</asp:Label>
                                <table class="tblDiscomfort">
                                    <tr>
                                        <td style="text-align: left; width: 500px; padding-left: 10px; padding-right: 10px;">
                                            <asp:RadioButtonList ID="PatDiscomfortNurseRadioButtonList" runat="server"
                                                RepeatDirection="Vertical" RepeatLayout="Table" Enabled="true">
                                                <asp:ListItem Value="2" Text="<span style='padding-left:30px;'></span>None - resting comfortably throughout"></asp:ListItem>
                                                <asp:ListItem Value="3" Text="<span style='padding-left:30px;'></span>One or two episodes of mild discomfort, well tolerated"></asp:ListItem>
                                                <asp:ListItem Value="4" Text="<span style='padding-left:30px;'></span>More than two episodes of discomfort, adequately tolerated"></asp:ListItem>
                                                <asp:ListItem Value="5" Text="<span style='padding-left:30px;'></span>Significant discomfort,  experienced several times during procedure"></asp:ListItem>
                                                <asp:ListItem Value="6" Text="<span style='padding-left:30px;'></span>Extreme discomfort frequently during test"></asp:ListItem>
                                            </asp:RadioButtonList>
                                        </td>
                                    </tr>
                                </table>--%>
                                <uc1:SedationScore runat="server" ID="UCSedationScore" Visible="false" IsEnabled="false" />
                                <uc1:DiscomfortScore runat="server" ID="UCDiscomfortScore" Visible="false" IsEnabled="false" />
                            </fieldset>
                            <fieldset>
                                <legend>Patient perception of</legend>
                                <asp:Label runat="server">Discomfort:</asp:Label>
                                <table>
                                    <tr>
                                        <td>
                                            <div style="float: left; padding-top: 3px;">Was the procedure&nbsp;</div>
                                            <div style="float: left;">
                                                <asp:RadioButtonList ID="PatDiscomfortPatientRadioButtonList" runat="server" CellSpacing="1" CellPadding="1" RepeatDirection="Horizontal" RepeatLayout="Table">
                                                    <asp:ListItem Value="1" Text="Same" />
                                                    <asp:ListItem Value="2" Text="Better" />
                                                    <asp:ListItem Value="3" Text="Worse" />
                                                </asp:RadioButtonList>
                                            </div>
                                            <div style="float: left; padding-top: 5px; padding-left: 7px;">&nbsp;than you expected?</div>
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div style="height: auto; text-align: center; padding-top: 10px;">
                                <telerik:RadButton ID="SavePatientComfortLevelsRadButton" runat="server" Text="Save" Skin="Metro" OnClick="SavePatientComfortLevelsRadButton_Click" Icon-PrimaryIconCssClass="telerikSaveButton" />
                                <telerik:RadButton ID="CancelSavePatientComfortLevelsRadButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                            </div>
                        </td>
                    </tr>
                </table>
            </asp:Panel>
            <asp:Panel ID="BreathTestPanel" runat="server" Visible="false">
                <div id="BreathTestDiv" runat="server" style="width: 400px;">
                    <fieldset>
                        <legend>Test Results</legend>
                        <table>
                            <tr>
                                <td>
                                    <asp:RadioButtonList ID="BreathTestResultRadioButtonList" runat="server" RepeatDirection="Horizontal">
                                        <asp:ListItem Value="1">Positive</asp:ListItem>
                                        <asp:ListItem Value="0">Negative</asp:ListItem>
                                        <asp:ListItem Value="2">Inconclusive</asp:ListItem>
                                    </asp:RadioButtonList>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                <div style="height: auto; text-align: center; padding-top: 10px;">
                    <telerik:RadButton ID="SaveBreathTestResultsRadButton" runat="server" Text="Save" Skin="Metro" OnClick="SaveBreathTestResultsRadButton_Click" Icon-PrimaryIconCssClass="telerikSaveButton" />

                    <telerik:RadButton ID="CancelSaveBreathTestResultsRadButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />

                </div>
            </asp:Panel>
        </div>
    </form>
    <telerik:RadScriptBlock ID="RadScriptBlock11" runat="server">
        <script type="text/javascript">

</script>
    </telerik:RadScriptBlock>
</body>
</html>
