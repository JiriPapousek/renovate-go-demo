package main

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello from Renovate Go Demo!",
		})
	})

	fmt.Println("Server starting on :8080")
	r.Run(":8080")
}
