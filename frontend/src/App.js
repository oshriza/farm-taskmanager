// @bekbrace
// FARMSTACK Tutorial - Sunday 13.06.2021
 
import React, { useState, useEffect} from 'react';
import './App.css';
import TodoView from './components/TodoListView';
import axios from 'axios';
import 'bootstrap/dist/css/bootstrap.min.css'; 


function App() {

  const [todoList, setTodoList] = useState([{}])
  const [title, setTitle] = useState('') 
  const [desc, setDesc] = useState('')

  // Read all todos
  useEffect(() => {
    axios.get('/api/todo')
      .then(res => {
        setTodoList(res.data)
      })
  }, []);

  // Post a todo
  const addTodoHandler = () => {
    if( title !== "") {
      axios.post('/api/todo/', { 'title': title, 'description': desc })
      .then(res => console.log(res))
    } else {
      alert("Please provide a title!")
    }
    window.location.reload();
  };

  const updateDescription = () => {
    if( title !== "") {
      axios.put(`/api/todo/${title}/?desc=${desc}`)
      .then(res => console.log(res))
    } else {
      alert("Please provide a title!")
    }
    window.location.reload();
  };

  return (
    <div className="App list-group-item justify-content-center align-items-center mx-auto" style={{"width":"450px", "backgroundColor":"white", "marginTop":"20px"}} >
      <h1 className="card text-dark mb-1" style={{"backgroundColor":"#FAAA34", "max-width": "20rem;"}} >Task Manager</h1>
      <h6 className="card text-dark mb-3" style={{"backgroundColor":"#FAAA34"}}>FASTAPI - React - MongoDB</h6>
     <div className="card-body">
      <h5 className="card text-white bg-dark mb-3">Add Your Task</h5>
      <span className="card-text"> 
        <input className="mb-2 form-control titleIn" onChange={event => setTitle(event.target.value)} placeholder='Title'/> 
        <input className="mb-2 form-control desIn" onChange={event => setDesc(event.target.value)}   placeholder='Description'/>
      <button className="btn btn-outline-primary mx-2 mb-3" style={{'borderRadius':'50px',"font-weight":"bold"}}  onClick={addTodoHandler}>Add Task</button>
      <button className="btn btn-outline-primary mx-2 mb-3" style={{'borderRadius':'50px',"font-weight":"bold"}}  onClick={updateDescription}>Update Description</button>
      </span>
      <h5 className="card text-white bg-dark mb-3">Your Tasks</h5>
      <div >
      <TodoView todoList={todoList} />
      </div>
      </div>
      <h6 className="card text-dark py-1 mb-0" style={{"backgroundColor":"#FAAA34"}} >Develeap bootcamp 14 - Portfolio | Oshri Zafrani</h6>
    </div>
  );
}

export default App;