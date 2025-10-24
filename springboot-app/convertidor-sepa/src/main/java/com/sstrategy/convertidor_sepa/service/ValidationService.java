package com.sstrategy.convertidor_sepa.service;

import java.io.InputStream;

import javax.xml.XMLConstants;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import com.sstrategy.convertidor_sepa.exception.ValidationException;

import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.xml.sax.SAXException;

@Service
public class ValidationService {
    public void validate(byte[] xmlData, String xsdPath) throws ValidationException {
        try (InputStream xmlStream = new java.io.ByteArrayInputStream(xmlData)) {
            ClassPathResource xsdResource = new ClassPathResource(xsdPath);

            SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
            Schema schema = schemaFactory.newSchema(xsdResource.getFile());
            Validator validator = schema.newValidator();
            validator.validate(new StreamSource(xmlStream));
        } catch (SAXException e) {
            throw new ValidationException("Error de validación XSD (" + xsdPath + "): " + e.getMessage(), e);
        } catch (Exception e) {
            throw new ValidationException("Error al validar XML con " + xsdPath + ": " + e.getMessage(), e);
        }
    }

}
