package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

const (
	imageMapFileName = "image_map.txt"
)

type ResponseWithLink struct {
	Id   int    `json:"id"`
	Link string `json:"link"`
}

type Config struct {
	domainName string
	bucketName string
}

var config Config

func randomImage() (int, error) {
	// TODO download image_map.txt file
	i := 1
	return i, nil
}

func handleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	fmt.Println("handling request ", request.Path)

	image, err := randomImage()

	if err != nil {
		fmt.Println("error retrieving random link - ", err.Error())
		return events.APIGatewayProxyResponse{StatusCode: 500, Body: "internal error"}, err
	}

	responseBody := ResponseWithLink{
		// s://DOMAIN/img/IMG NAME
		Link: fmt.Sprintf("https://%s/img/%s", config.domainName, image.Path),
		Id:   image.Id,
	}

	responseBodyJsonBytes, err := json.Marshal(responseBody)

	if err != nil {
		fmt.Println("error marshalling JSON - ", err.Error())
		return events.APIGatewayProxyResponse{StatusCode: 500, Body: "internal error"}, err
	}

	response := events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(responseBodyJsonBytes),
	}

	return response, nil
}

func main() {
	fmt.Println("hello world")
	context.Background()

	config.bucketName = os.Getenv("BUCKET_NAME")
	config.domainName = os.Getenv("DOMAIN_NAME")

	lambda.Start(handleRequest)
}
