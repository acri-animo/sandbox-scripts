import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Fade, TextField, InputAdornment, IconButton } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import Typist from 'react-typist';

import Nui from '../../../util/Nui';
import { useAlert } from '../../../hooks';

const useStyles = makeStyles((theme) => ({
  wrapper: {
    height: "80%",
    width: "100%",
    background: "#16213e",
    position: "absolute",
  },
  inner: {
    width: "100%",
    height: "fit-content",
    position: "absolute",
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    margin: "auto",
    textAlign: "center",
  },
  header: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#8685EF",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
  },
  body: {
    padding: "0px 30px",
    color: "white",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
  },
  creatorInput: {
    margin: "10px 0",
    "& .MuiOutlinedInput-root": {
      background: "rgba(255, 255, 255, 0.05)",
      borderRadius: "8px",
      "& fieldset": {
        borderColor: "rgba(134, 133, 239, 0.3)",
        transition: "border-color 0.2s ease",
      },
      "&:hover fieldset": {
        borderColor: "rgba(134, 133, 239, 0.5)",
      },
      "&.Mui-focused fieldset": {
        borderColor: "#8685EF",
        boxShadow: "0 0 0 1px rgba(134, 133, 239, 0.2)",
      },
    },
    "& .MuiInputLabel-root": {
      color: "rgba(255, 255, 255, 0.7)",
      "&.Mui-focused": {
        color: "#8685EF",
      },
    },
    "& .MuiInputBase-input": {
      color: "white",
    },
  },
  submitButton: {
    color: "#8685EF",
    transition: "all 0.2s ease",
    "&:hover": {
      background: "rgba(134, 133, 239, 0.1)",
    },
  },
  note: {
    color: "rgba(255, 255, 255, 0.6)",
    fontSize: "14px",
    fontStyle: "italic",
    marginTop: "16px",
  },
}))

export default () => {
  const classes = useStyles()
  const showAlert = useAlert()
  const dispatch = useDispatch()
  const player = useSelector((state) => state.data.data.player)

  const [show, setShow] = useState(false)
  const onAnimEnd = () => {
    setShow(true)
  }

  const onSubmit = async (e) => {
    e.preventDefault()
    const ta = e.target.alias.value
    try {
      const res = await (
        await Nui.send("UpdateRacerAlias", {
          app: "redline",
          name: ta,
          picture: "",
        })
      ).json()
      showAlert(res ? "Alias Created" : "Unable to Create Alias")

      if (res) {
        dispatch({
          type: "UPDATE_DATA",
          payload: {
            type: "player",
            id: "Profiles",
            key: "redline",
            data: {
              sid: player.SID,
              app: "redline",
              name: ta,
              picture: "",
              meta: {},
            },
          },
        })
      }
    } catch (err) {
      console.error(err)
      showAlert("Unable to Create Alias")
    }
  }

  return (
    <div className={classes.wrapper}>
      <div className={classes.inner}>
        <div className={classes.header}>
          <Typist onTypingDone={onAnimEnd}>
            <span>Welcome Racer</span>
          </Typist>
        </div>
        <Fade in={show}>
          <div className={classes.body}>
            <p>Set your alias to get started</p>
            <form onSubmit={onSubmit}>
              <TextField
                className={classes.creatorInput}
                fullWidth
                label="Alias"
                name="alias"
                variant="outlined"
                required
                InputProps={{
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton type="submit" className={classes.submitButton}>
                        <FontAwesomeIcon icon={["far", "octagon-check"]} />
                      </IconButton>
                    </InputAdornment>
                  ),
                }}
                inputProps={{
                  maxLength: 32,
                }}
              />
            </form>
            <p className={classes.note}>Think hard, you may not change this</p>
          </div>
        </Fade>
      </div>
    </div>
  )
}

