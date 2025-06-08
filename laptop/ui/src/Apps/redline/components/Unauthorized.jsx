import React, { useState } from 'react';
import { Fade } from '@mui/material';
import { makeStyles } from '@mui/styles';
import Typist from 'react-typist';

const useStyles = makeStyles((theme) => ({
  wrapper: {
    height: "100%",
    background: "#16213e",
    textAlign: "center",
  },
  header: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#ff6b6b",
    margin: "auto",
    position: "absolute",
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    height: "fit-content",
    width: "fit-content",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
  },
  body: {
    margin: "auto",
    position: "absolute",
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    paddingTop: 75,
    height: "fit-content",
    width: "fit-content",
    color: "white",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
  },
}))

export default (props) => {
  const classes = useStyles()

  const [show, setShow] = useState(false)
  const onAnimEnd = () => {
    setShow(true)
  }

  return (
    <div className={classes.wrapper}>
      <div className={classes.header}>
        <Typist onTypingDone={onAnimEnd}>
          <span>You Are Not Authorized</span>
        </Typist>
      </div>
      {show && (
        <Fade in={true}>
          <div className={classes.body}>
            <Typist onTypingDone={onAnimEnd}>
              <span>Immediately Stop What You Are Doing</span>
            </Typist>
          </div>
        </Fade>
      )}
    </div>
  )
}
