<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="GuidelinesForSedation.aspx.vb" Inherits="UnisoftERS.GuidelinesForSedation" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Guidelines for Sedation</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        body {
            font-family: helvetica, arial, sans-serif;
            font-size: 10px;
            font-weight: 200;
        }

        div.table-title {
            display: block;
            padding: 5px;
        }

        .table-title h3 {
            color: #4c4d4f;
            font-size: 30px;
            font-weight: 400;
            font-style: normal;
            font-family: helvetica, arial, sans-serif;
            text-shadow: -1px -1px 1px rgba(0, 0, 0, 0.1);
        }

        .smalltext {
            margin: 10px;
            display: block;
            padding: 5px;
            color: #4c4d4f;
            font-size: 13px;
            font-weight: 400;
            font-style: normal;
            font-family: helvetica, arial, sans-serif;
        }

        .table-fill {
            background: white;
            border-radius: 3px;
            border-collapse: collapse;
            height: 320px;
            margin: auto;
            padding: 5px;
            box-shadow: 0 5px 10px rgba(0, 0, 0, 0.1);
        }

        th {
            color: #D5DDE5;
            background: #4c4d4f;
            border-bottom: 4px solid #9ea7af;
            border-right: 1px solid #343a45;
            font-size: 15px;
            font-weight: 100;
            padding: 24px;
            text-align: left;
            text-shadow: 0 1px 1px rgba(0, 0, 0, 0.1);
            vertical-align: middle;
        }

            th:first-child {
                border-top-left-radius: 3px;
            }

            th:last-child {
                border-top-right-radius: 3px;
                border-right: none;
            }

        tr {
            border-top: 1px solid #C1C3D1;
            border-bottom: 1px solid #C1C3D1;
            color: #666B85;
            font-size: 10px;
            font-weight: normal;
            background: #f2f2f2;
        }

            tr:first-child {
                border-top: none;
            }

            tr:last-child {
                border-bottom: 2px solid #D5DDE5;
            }

            tr:nth-child(odd) td {
                background: #EBEBEB;
            }

            tr:last-child td:first-child {
                border-bottom-left-radius: 3px;
            }

            tr:last-child td:last-child {
                border-bottom-right-radius: 3px;
            }

        td {
            padding: 20px;
            text-align: left;
            vertical-align: middle;
            font-weight: 300;
            font-size: 15px;
            border-right: 1px solid #C1C3D1;
            
        }

            td:first-child {
                font-weight: bold;
            }

            td:last-child {
                border-right: 0px;
            }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div class="table-title">
                <h3>Guidelines for Sedation</h3>
            </div>
            <table>
                <thead>
                    <tr>
                        <th></th>
                        <th>No Sedation</th>
                        <th>Minimal Sedation/Anxiolysis</th>
                        <th>Moderate Sedation / Analgesia ("Conscious Sedation")</th>
                        <th>Deep Sedation/Analgesia</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Responsiveness</td>
                        <td></td>
                        <td>Normal response to verbal stimulation</td>
                        <td>Purposeful* response to verbal or tactile stimulation</td>
                        <td>Purposeful* response following repeated or painful stimulation</td>
                    </tr>
                    <tr>
                        <td>Airway</td>
                        <td></td>
                        <td>Unaffected</td>
                        <td>No intervention required</td>
                        <td>Intervention may be required</td>
                    </tr>
                    <tr>
                        <td>Spontaneous ventalation</td>
                        <td></td>
                        <td>Unaffected</td>
                        <td>Adequate</td>
                        <td>May be inadequate</td>
                    </tr>
                    <tr>
                        <td>Cardiovascular function</td>
                        <td></td>
                        <td>Unaffected</td>
                        <td>Usually maintained</td>
                        <td>Usually maintained</td>
                    </tr>
                </tbody>
            </table>

            <div class="smalltext">
                * Reflux withdrawal from a painful stimulus is NOT considered a purposeful response. 
            </div>
        </div>
    </form>
</body>
</html>
