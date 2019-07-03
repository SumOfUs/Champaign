//
import React from 'react';

function TargetsStatusTable(props) {
  const data = props.data;
  return (
    <table className="table totals">
      <tbody>
        <tr>
          <th> Failed </th>
          <td> {data.failed} </td>
        </tr>
        <tr>
          <th> No Answer </th>
          <td> {data['no-answer']} </td>
        </tr>
        <tr>
          <th> Busy </th>
          <td> {data.busy} </td>
        </tr>
        <tr>
          <th> Completed </th>
          <td> {data.completed}</td>
        </tr>
        <tr>
          <th> Total </th>
          <td> {data.total} </td>
        </tr>
      </tbody>
    </table>
  );
}

export default TargetsStatusTable;
