// @bekbrace
// FARMSTACK Tutorial - Sunday 13.06.2021
import axios from 'axios'
import React from 'react'

function TodoItem(props) {
    const deleteTodoHandler = (title) => {
    axios.delete(`/api/todo/${title}`)
        .then(res => console.log(res.data))
        window.location.reload();
     }
  
    return (
        <div>
            <p>
                <span style={{ fontWeight: 'bold, underline' }}>{props.todo.title} : </span> {props.todo.description} 
                <button onClick={() => deleteTodoHandler(props.todo.title)} className="btn btn-outline-danger my-2 mx-2" style={{'borderRadius':'50px', 'width': '40px', 'border': '2px solid'}}>X</button>
                <hr></hr>
            </p>
        </div>
    )
}

export default TodoItem;