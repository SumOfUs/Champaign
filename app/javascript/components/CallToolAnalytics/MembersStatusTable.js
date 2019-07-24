//
import React from 'react';

function MembersStatusTable(props) {
  const data = props.data;
  return (
    <table className="table totals">
      <tbody>
        <tr>
          <th> Unstarted </th>
          <td> {data.unstarted} </td>
        </tr>
        <tr>
          <th> Started </th>
          <td> {data.started} </td>
        </tr>
        <tr>
          <th> Connected </th>
          <td> {data.connected}</td>
        </tr>
        <tr>
          <th> Total </th>
          <td> {data.total} </td>
        </tr>
      </tbody>
    </table>
  );
}

export default MembersStatusTable;
