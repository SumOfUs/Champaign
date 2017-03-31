import React, { Component } from 'react';

type OwnProps = {
  data: any
}

function MembersLastWeekTable(props:OwnProps) {
  const data = props.data;
  return(
    <table className="table totals">
      <tbody>
        <tr>
          <th> Failed </th>
          <td> { data.failed } </td>
        </tr>
        <tr>
          <th> Unstarted </th>
          <td> { data.unstarted } </td>
        </tr>
        <tr>
          <th> Started </th>
          <td> { data.started } </td>
        </tr>
        <tr>
          <th> Connected </th>
          <td> { data.connected }</td>
        </tr>
        <tr>
          <th> Total </th>
          <td> { data.total } </td>
        </tr>
      </tbody>
    </table>
  );
}

export default MembersLastWeekTable;
